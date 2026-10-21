"""Read-only ECS service health verifier.

Invoked by the Terraform ``aws_lambda_invoke`` action after governed
remediation (for example, after a codified desired_count baseline is applied).

Event::

    {
      "cluster": "payments-production",
      "service": "payments-api",
      "expected_task_count": 6,
      "fail_on_fail": true          # optional, default false
    }

The function calls ``ecs:DescribeServices`` and nothing else. It never
modifies ECS resources.

IMPORTANT: a successful Lambda invocation only means the function ran. The
health verdict is the ``status`` field ("PASS" or "FAIL") in the returned
payload. When ``fail_on_fail`` is true, a FAIL verdict raises
``HealthCheckFailed`` so the invoking tool (for example a Terraform action)
reports an error instead of a green invocation.

A compact verdict (status, summary, observed counts, failed checks) is also
printed on one log line prefixed ``ECS_HEALTH_VERDICT``. The Terraform action
does not display the response payload; with ``log_type = "Tail"`` it shows the
last 4 KB of this log, so the line is kept small enough to always fit.
"""

import json
from datetime import datetime, timezone

VERDICT_LOG_PREFIX = "ECS_HEALTH_VERDICT"
MAX_EVENTS = 3
MAX_EVENT_MESSAGE_LENGTH = 200


class HealthCheckFailed(Exception):
    """Raised on a FAIL verdict when fail_on_fail is enabled.

    The message is the verdict JSON, which Lambda returns as ``errorMessage``.
    """


def _check(name, passed, expected, actual):
    return {"name": name, "pass": bool(passed), "expected": expected, "actual": actual}


def _deployment_summary(deployment):
    return {
        "id": deployment.get("id"),
        "status": deployment.get("status"),
        "rollout_state": deployment.get("rolloutState"),
        "rollout_state_reason": deployment.get("rolloutStateReason"),
        "desired_count": deployment.get("desiredCount"),
        "running_count": deployment.get("runningCount"),
        "pending_count": deployment.get("pendingCount"),
        "failed_tasks": deployment.get("failedTasks"),
    }


def _recent_events(service):
    events = []
    for event in (service.get("events") or [])[:MAX_EVENTS]:
        events.append(
            {
                "created_at": str(event.get("createdAt")),
                "message": str(event.get("message", ""))[:MAX_EVENT_MESSAGE_LENGTH],
            }
        )
    return events


def evaluate_service(response, expected_task_count):
    """Evaluate a DescribeServices response. Returns (checks, observed, diagnostics)."""
    failures = response.get("failures") or []
    services = response.get("services") or []
    service = services[0] if services else None

    checks = [
        _check(
            "describe_services_failures",
            not failures,
            [],
            [f.get("reason") or f.get("detail") for f in failures],
        ),
        _check("service_found", service is not None, True, service is not None),
    ]
    diagnostics = {"failures": failures}

    if service is None:
        return checks, None, diagnostics

    deployments = service.get("deployments") or []
    primary = next((d for d in deployments if d.get("status") == "PRIMARY"), None)

    desired = service.get("desiredCount")
    running = service.get("runningCount")
    pending = service.get("pendingCount")

    observed = {
        "status": service.get("status"),
        "desired_count": desired,
        "running_count": running,
        "pending_count": pending,
        "deployment_count": len(deployments),
        "deployment_rollout_state": primary.get("rolloutState") if primary else None,
        "deployments": [_deployment_summary(d) for d in deployments],
    }

    checks.extend(
        [
            _check("service_active", service.get("status") == "ACTIVE", "ACTIVE", service.get("status")),
            _check("desired_count_matches_expected", desired == expected_task_count, expected_task_count, desired),
            _check("running_equals_desired", running == desired, desired, running),
            _check("pending_is_zero", pending == 0, 0, pending),
            _check("single_deployment", len(deployments) == 1, 1, len(deployments)),
            _check(
                "deployment_rollout_completed",
                primary is not None and primary.get("rolloutState") == "COMPLETED",
                "COMPLETED",
                primary.get("rolloutState") if primary else None,
            ),
            _check(
                "no_failed_tasks",
                primary is not None and primary.get("failedTasks") == 0,
                0,
                primary.get("failedTasks") if primary else None,
            ),
        ]
    )
    diagnostics["recent_events"] = _recent_events(service)
    if primary and primary.get("rolloutStateReason"):
        diagnostics["rollout_state_reason"] = primary.get("rolloutStateReason")
    return checks, observed, diagnostics


def _summary(status, cluster, service, checks, observed):
    if status == "PASS":
        return (
            "PASS: %s/%s healthy (desired=%s running=%s pending=%s, deployment=%s)"
            % (
                cluster,
                service,
                observed["desired_count"],
                observed["running_count"],
                observed["pending_count"],
                observed["deployment_rollout_state"],
            )
        )
    failed = [c["name"] for c in checks if not c["pass"]]
    return "FAIL: %d of %d checks failed: %s" % (len(failed), len(checks), ", ".join(failed))


def _validate_event(event):
    if not isinstance(event, dict):
        raise ValueError("event must be a JSON object")
    for key in ("cluster", "service"):
        value = event.get(key)
        if not isinstance(value, str) or not value.strip():
            raise ValueError("'%s' is required and must be a non-empty string" % key)
    expected = event.get("expected_task_count")
    if isinstance(expected, bool) or not isinstance(expected, int) or expected < 0:
        raise ValueError("'expected_task_count' is required and must be an integer >= 0")
    fail_on_fail = event.get("fail_on_fail", False)
    if not isinstance(fail_on_fail, bool):
        raise ValueError("'fail_on_fail' must be a boolean")
    return event["cluster"].strip(), event["service"].strip(), expected, fail_on_fail


def _default_client():
    import boto3  # available in the Lambda runtime; imported lazily for unit tests

    return boto3.client("ecs")


def build_verdict(cluster, service, expected_task_count, ecs_client):
    """Run the read-only check and return the structured verdict (never raises on ECS errors)."""
    try:
        response = ecs_client.describe_services(cluster=cluster, services=[service])
    except Exception as exc:  # report API errors (AccessDenied, ClusterNotFound, ...) as FAIL
        checks = [_check("describe_services_call", False, "success", type(exc).__name__)]
        observed = None
        diagnostics = {"error_type": type(exc).__name__, "error_message": str(exc)[:500]}
    else:
        checks, observed, diagnostics = evaluate_service(response, expected_task_count)

    status = "PASS" if all(c["pass"] for c in checks) else "FAIL"
    return {
        "status": status,
        "summary": _summary(status, cluster, service, checks, observed),
        "cluster": cluster,
        "service": service,
        "expected_task_count": expected_task_count,
        "observed": observed,
        "checks": checks,
        "diagnostics": diagnostics,
        "evaluated_at": datetime.now(timezone.utc).isoformat(),
    }


def compact_verdict(verdict):
    """Small log-friendly view: no deployment list, events, or passing checks."""
    observed = verdict["observed"]
    if observed is not None:
        observed = {k: v for k, v in observed.items() if k != "deployments"}
    return {
        "status": verdict["status"],
        "summary": verdict["summary"],
        "cluster": verdict["cluster"],
        "service": verdict["service"],
        "expected_task_count": verdict["expected_task_count"],
        "observed": observed,
        "failed_checks": [c["name"] for c in verdict["checks"] if not c["pass"]],
    }


def lambda_handler(event, context, ecs_client=None):
    cluster, service, expected, fail_on_fail = _validate_event(event)
    verdict = build_verdict(cluster, service, expected, ecs_client or _default_client())
    verdict_json = json.dumps(verdict, sort_keys=True, default=str)
    print("%s %s" % (VERDICT_LOG_PREFIX, json.dumps(compact_verdict(verdict), sort_keys=True, default=str)))

    if verdict["status"] == "FAIL" and fail_on_fail:
        raise HealthCheckFailed(verdict_json)
    return json.loads(verdict_json)
