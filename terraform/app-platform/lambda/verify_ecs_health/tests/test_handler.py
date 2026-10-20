"""Unit tests for the read-only ECS health verifier. No AWS access required."""

import json
import os
import sys
import unittest
from contextlib import redirect_stdout
from io import StringIO

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import handler  # noqa: E402

CLUSTER = "payments-production"
SERVICE = "payments-api"


def deployment(**overrides):
    base = {
        "id": "ecs-svc/1",
        "status": "PRIMARY",
        "rolloutState": "COMPLETED",
        "rolloutStateReason": "ECS deployment completed successfully.",
        "desiredCount": 6,
        "runningCount": 6,
        "pendingCount": 0,
        "failedTasks": 0,
    }
    base.update(overrides)
    return base


def service(**overrides):
    base = {
        "serviceName": SERVICE,
        "status": "ACTIVE",
        "desiredCount": 6,
        "runningCount": 6,
        "pendingCount": 0,
        "deployments": [deployment()],
        "events": [{"createdAt": "2026-01-01T00:00:00Z", "message": "service has reached a steady state."}],
    }
    base.update(overrides)
    return base


class FakeEcsClient:
    """Records calls; only describe_services exists, so any other ECS call fails the test."""

    def __init__(self, response=None, error=None):
        self.response = response
        self.error = error
        self.calls = []

    def describe_services(self, **kwargs):
        self.calls.append(kwargs)
        if self.error:
            raise self.error
        return self.response


def event(**overrides):
    base = {"cluster": CLUSTER, "service": SERVICE, "expected_task_count": 6}
    base.update(overrides)
    return base


def run(ev, client):
    out = StringIO()
    with redirect_stdout(out):
        result = handler.lambda_handler(ev, None, ecs_client=client)
    return result, out.getvalue()


def failed_checks(result):
    return {c["name"] for c in result["checks"] if not c["pass"]}


class HealthyServiceTests(unittest.TestCase):
    def test_pass_when_all_counts_match_and_deployment_complete(self):
        client = FakeEcsClient({"services": [service()], "failures": []})
        result, _ = run(event(), client)

        self.assertEqual(result["status"], "PASS")
        self.assertEqual(failed_checks(result), set())
        self.assertEqual(result["observed"]["desired_count"], 6)
        self.assertEqual(result["observed"]["running_count"], 6)
        self.assertEqual(result["observed"]["pending_count"], 0)
        self.assertEqual(result["observed"]["deployment_rollout_state"], "COMPLETED")
        self.assertTrue(result["summary"].startswith("PASS"))

    def test_only_describe_services_is_called_with_exact_arguments(self):
        client = FakeEcsClient({"services": [service()], "failures": []})
        run(event(), client)

        self.assertEqual(client.calls, [{"cluster": CLUSTER, "services": [SERVICE]}])
        # The fake exposes no mutating methods; guard against accidental additions.
        self.assertEqual([m for m in dir(client) if not m.startswith("_") and callable(getattr(client, m))], ["describe_services"])


class UnhealthyServiceTests(unittest.TestCase):
    def verdict(self, svc, expected=6, failures=None):
        client = FakeEcsClient({"services": [svc], "failures": failures or []})
        result, _ = run(event(expected_task_count=expected), client)
        return result

    def test_fail_when_desired_count_differs_from_expected(self):
        # Drift scenario: baseline codified as 6 but verifying against the old value 3.
        result = self.verdict(service(), expected=3)
        self.assertEqual(result["status"], "FAIL")
        self.assertIn("desired_count_matches_expected", failed_checks(result))
        self.assertEqual(result["observed"]["desired_count"], 6)

    def test_fail_when_running_below_desired(self):
        result = self.verdict(service(runningCount=4, pendingCount=0))
        self.assertEqual(result["status"], "FAIL")
        self.assertIn("running_equals_desired", failed_checks(result))
        self.assertEqual(result["observed"]["running_count"], 4)

    def test_fail_when_tasks_pending(self):
        result = self.verdict(service(runningCount=5, pendingCount=1))
        self.assertEqual(result["status"], "FAIL")
        self.assertIn("pending_is_zero", failed_checks(result))

    def test_fail_when_service_not_active(self):
        result = self.verdict(service(status="DRAINING"))
        self.assertIn("service_active", failed_checks(result))

    def test_fail_when_rollout_in_progress_with_two_deployments(self):
        deployments = [
            deployment(rolloutState="IN_PROGRESS"),
            deployment(id="ecs-svc/0", status="ACTIVE"),
        ]
        result = self.verdict(service(deployments=deployments))
        self.assertEqual(result["status"], "FAIL")
        failed = failed_checks(result)
        self.assertIn("single_deployment", failed)
        self.assertIn("deployment_rollout_completed", failed)
        self.assertEqual(result["observed"]["deployment_count"], 2)

    def test_fail_when_rollout_failed_with_failed_tasks(self):
        deployments = [deployment(rolloutState="FAILED", rolloutStateReason="tasks failed to start", failedTasks=3)]
        result = self.verdict(service(deployments=deployments))
        failed = failed_checks(result)
        self.assertIn("deployment_rollout_completed", failed)
        self.assertIn("no_failed_tasks", failed)
        self.assertEqual(result["diagnostics"]["rollout_state_reason"], "tasks failed to start")

    def test_fail_when_service_missing_in_failures(self):
        client = FakeEcsClient({"services": [], "failures": [{"arn": "arn:x", "reason": "MISSING"}]})
        result, _ = run(event(), client)
        self.assertEqual(result["status"], "FAIL")
        self.assertIn("service_found", failed_checks(result))
        self.assertIn("describe_services_failures", failed_checks(result))
        self.assertIsNone(result["observed"])

    def test_api_error_is_reported_as_fail_not_exception(self):
        client = FakeEcsClient(error=RuntimeError("AccessDeniedException: not authorized"))
        result, _ = run(event(), client)
        self.assertEqual(result["status"], "FAIL")
        self.assertEqual(result["diagnostics"]["error_type"], "RuntimeError")
        self.assertIsNone(result["observed"])

    def test_events_are_limited_and_truncated(self):
        events = [{"createdAt": "t%d" % i, "message": "m" * 1000} for i in range(10)]
        result = self.verdict(service(events=events))
        recent = result["diagnostics"]["recent_events"]
        self.assertEqual(len(recent), handler.MAX_EVENTS)
        self.assertTrue(all(len(e["message"]) <= handler.MAX_EVENT_MESSAGE_LENGTH for e in recent))


class OutputContractTests(unittest.TestCase):
    def test_result_is_json_serializable_with_required_fields(self):
        client = FakeEcsClient({"services": [service()], "failures": []})
        result, _ = run(event(), client)
        json.dumps(result)
        for key in ("status", "summary", "cluster", "service", "expected_task_count", "observed", "checks", "diagnostics", "evaluated_at"):
            self.assertIn(key, result)
        for check in result["checks"]:
            self.assertEqual(set(check), {"name", "pass", "expected", "actual"})

    def test_verdict_is_logged_on_single_prefixed_line(self):
        client = FakeEcsClient({"services": [service(runningCount=2)], "failures": []})
        result, stdout = run(event(), client)
        lines = [l for l in stdout.splitlines() if l.startswith(handler.VERDICT_LOG_PREFIX)]
        self.assertEqual(len(lines), 1)
        logged = json.loads(lines[0][len(handler.VERDICT_LOG_PREFIX) + 1:])
        self.assertEqual(logged["status"], "FAIL")
        self.assertEqual(logged["observed"]["running_count"], 2)
        self.assertEqual(logged["failed_checks"], ["running_equals_desired"])
        self.assertNotIn("deployments", logged["observed"])

    def test_logged_line_fits_in_log_tail_even_for_noisy_failures(self):
        events = [{"createdAt": "t", "message": "m" * 1000} for _ in range(10)]
        client = FakeEcsClient({"services": [service(runningCount=0, pendingCount=6, events=events)], "failures": []})
        _, stdout = run(event(), client)
        self.assertLess(len(stdout.encode()), 2048)


class FailOnFailTests(unittest.TestCase):
    def test_fail_returns_normally_by_default(self):
        client = FakeEcsClient({"services": [service(runningCount=1)], "failures": []})
        result, _ = run(event(), client)
        self.assertEqual(result["status"], "FAIL")

    def test_fail_raises_when_fail_on_fail_enabled(self):
        client = FakeEcsClient({"services": [service(runningCount=1)], "failures": []})
        with self.assertRaises(handler.HealthCheckFailed) as ctx:
            run(event(fail_on_fail=True), client)
        self.assertEqual(json.loads(str(ctx.exception))["status"], "FAIL")

    def test_pass_does_not_raise_when_fail_on_fail_enabled(self):
        client = FakeEcsClient({"services": [service()], "failures": []})
        result, _ = run(event(fail_on_fail=True), client)
        self.assertEqual(result["status"], "PASS")


class InputValidationTests(unittest.TestCase):
    def assert_invalid(self, ev):
        client = FakeEcsClient({"services": [], "failures": []})
        with self.assertRaises(ValueError):
            run(ev, client)
        self.assertEqual(client.calls, [])  # no ECS call on invalid input

    def test_rejects_non_dict_event(self):
        self.assert_invalid("nope")

    def test_rejects_missing_or_blank_cluster_and_service(self):
        self.assert_invalid({"service": SERVICE, "expected_task_count": 6})
        self.assert_invalid(event(cluster="  "))
        self.assert_invalid(event(service=""))

    def test_rejects_bad_expected_task_count(self):
        for bad in (None, "6", 6.0, True, -1):
            self.assert_invalid(event(expected_task_count=bad))

    def test_rejects_non_boolean_fail_on_fail(self):
        self.assert_invalid(event(fail_on_fail="yes"))


if __name__ == "__main__":
    unittest.main()
