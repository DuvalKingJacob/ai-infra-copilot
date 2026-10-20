# ECS Service Stability Verification Action

Adds a read-only check that confirms the `payments-api` ECS service converged to
the approved capacity with a completed deployment after governed remediation
(the drift scenario: 3 tasks, manual scale to 6, approved Terraform baseline of
6, clean verification).

**Scope:** this verifies ECS *service stability*, not comprehensive application
health. The service has no load balancer, so there are no target-group health
signals, and the check does not read per-task health. Describe it to an
audience as "did the service converge to six tasks with a completed
deployment", not "is the application healthy".

Nothing here changes `aws_ecs_service.api`, its desired count, or the workspace
credentials. The action has no `action_trigger`; it runs only when invoked.

## What was added

| File | Purpose |
| --- | --- |
| `terraform/app-platform/verify-ecs-health.tf` | Lambda, least-privilege role, log group, and `action "aws_lambda_invoke" "verify_ecs_health"` |
| `terraform/app-platform/lambda/verify_ecs_health/handler.py` | Python 3.12 handler; only calls `ecs:DescribeServices` |
| `terraform/app-platform/lambda/verify_ecs_health/tests/test_handler.py` | Unit tests with a stubbed ECS client (no AWS access) |
| `docs/iam/hcp-run-role-verify-ecs-health.draft.json` | **Draft** extra permissions for the HCP run role. Not applied |

## What the check evaluates

Input: `cluster`, `service`, `expected_task_count`, optional `fail_on_fail`.

PASS requires all of these:

- `DescribeServices` returned no `failures` and the service was found.
- Service `status` is `ACTIVE`.
- `desiredCount` equals `expected_task_count` (defaults to `var.desired_count`, which is 6 in the workspace).
- `runningCount` equals `desiredCount`.
- `pendingCount` is 0.
- Exactly one deployment, with `rolloutState` `COMPLETED` and `failedTasks` 0.

The Lambda returns JSON with `status` (`PASS` or `FAIL`), `summary`, `observed`
(counts, deployment rollout state and list), a per-check list, and diagnostics
(recent events, rollout reason, failures). ECS API errors become a `FAIL`
verdict rather than an unhandled exception.

## A green invocation is not a passing health check

The AWS provider's `aws_lambda_invoke` action (checked against the provider
source for 6.67.0) behaves as follows:

- It prints `Lambda function … invoked successfully (status: 200, payload: N bytes)`. That only means the function ran.
- It does **not** display the response payload, so the returned `status` field is not shown in the run output.
- It fails the action only when Lambda reports a function error (an unhandled exception).
- With `log_type = "Tail"` it also prints the last 4 KB of the function log.

So this configuration does two things:

1. `log_type = "Tail"` is set, and the handler prints one compact line,
   `ECS_HEALTH_VERDICT {...}`, containing the status, summary, observed counts,
   and failed check names. The line stays under 2 KB (covered by a unit test).
2. `var.verify_fail_on_fail` (default `true`) is sent as `fail_on_fail`. On a
   FAIL the handler raises, so Lambda reports a function error and the action
   and run end in **error**, and the provider includes the Lambda error
   payload (the full verdict JSON) in the error message. A green action
   therefore means PASS.

Set `verify_fail_on_fail = false` to get a report-only run; in that mode the
verdict is only in the `ECS_HEALTH_VERDICT` line and must be read there.
The full JSON payload is returned by Lambda but not shown by Terraform; use
`aws lambda invoke` (below) when you need it.

## Invoking the action

The action is declared in the configuration, so it must be present in the
config version the run uses (that means merged to the workspace branch; this
feature branch is not deployed).

CLI, with a Terraform CLI connected to the workspace:

```bash
terraform apply -invoke=action.aws_lambda_invoke.verify_ecs_health
```

HCP Terraform Actions page (workspace, then **Actions**, then **Invoke action**):
requires Terraform 1.14+ and an HCP Terraform Standard plan or higher. Choose
**Preview with plan-only** to model it without invoking.

API, which works without the UI and is the supported alternative if the Actions
page is unavailable:

```json
POST /api/v2/runs
{
  "data": {
    "type": "runs",
    "attributes": {
      "message": "Verify ECS health after remediation",
      "invoke-action-addrs": ["action.aws_lambda_invoke.verify_ecs_health"]
    },
    "relationships": {
      "workspace": { "data": { "type": "workspaces", "id": "ws-CEELez65xPTRDHfH" } }
    }
  }
}
```

`invoke-action-addrs` takes one address and is exclusive with `target-addrs`
and `is-destroy`.

Outside Terraform, the Lambda can be invoked directly to get the complete JSON:

```bash
aws lambda invoke --function-name payments-production-verify-ecs-health \
  --cli-binary-format raw-in-base64-out \
  --payload '{"cluster":"payments-production","service":"payments-api","expected_task_count":6}' \
  /dev/stdout
```

To demonstrate FAIL without touching ECS, run with
`verify_expected_task_count = 3`.

## Versions

- Terraform `>= 1.14.0` (Actions requirement). The workspace uses `1.17.0-beta2`.
- AWS provider `~> 6.67.0`. `aws_lambda_invoke` was added in 6.14.0 and the `Tail` log output in 6.19.0 (provider CHANGELOG); 6.67.0 is the version already validated here.
- `hashicorp/archive` `~> 2.7` packages the handler.
- `.terraform.lock.hcl` is gitignored in this repo, so the constraints above are what keeps runs reproducible.

## Credentials and Vault

Provider authentication stays outside the configuration. The `provider "aws"`
block is region-only, and the workspace still authenticates through its existing
`TFC_AWS_*` dynamic credentials. When Vault-backed AWS credentials are
introduced, they replace those workspace variables; no change to
`verify-ecs-health.tf` is needed. The Lambda's own execution role is separate
from the provider credentials.

The run role (today, or Vault-issued later) needs the extra permissions in
`docs/iam/hcp-run-role-verify-ecs-health.draft.json` before this can be applied.
Review that file; it has not been applied and the existing role is untouched.

### Run role assessment (read-only, 2026-10-20)

Inspected `hcp-terraform-ai-infra-copilot` in account `009365819213` with
`iam get-role`, `list-attached-role-policies`, `get-role-policy` and
`simulate-principal-policy`. Nothing was modified.

- **Permissions boundary:** none.
- **Attached:** `ReadOnlyAccess`, `AmazonECS_FullAccess`, `CloudWatchFullAccess`.
- **Inline:** `app-platform-demo-permissions` (IAM write actions scoped to the
  task execution role only, EC2 security groups, `/ecs/payments-api` logs, ECS
  task definitions, the S3 bucket).
- **Trust:** web identity from `app.terraform.io`, audience
  `aws.workload.identity`, subject limited to
  `organization:Vearadyn:project:ai-infra-copilot:workspace:ai-infra-copilot:run_phase:*`.

Simulated result for the new resources, before and after the draft:

| Area | Already allowed | Missing (denied today) |
| --- | --- | --- |
| Lambda | Get/List reads | `CreateFunction`, `DeleteFunction`, `UpdateFunctionCode`, `UpdateFunctionConfiguration`, `TagResource`, `UntagResource`, `InvokeFunction` |
| IAM role | Get/List reads | `CreateRole`, `DeleteRole`, `UpdateAssumeRolePolicy`, `TagRole`, `UntagRole`, `PutRolePolicy`, `DeleteRolePolicy`, `PassRole` to Lambda |
| Log group | All needed actions, from `CloudWatchFullAccess` (`logs:*`) | None |

The draft adds only the missing actions, on the exact `payments-production`
function and role ARNs. With the draft added, the simulation allows every needed
action. It still denies `iam:PassRole` to other services, role changes on any
other role, Lambda actions on any other function, and `iam:AttachRolePolicy`.

Limits of this check:

- The simulation evaluates the role's identity policies and boundary only. It
  does not model SCPs, resource policies, or session policies. Run
  `aws organizations` or check for SCPs separately if the account is in an
  organization.
- It confirms permissions, not the exact API calls the provider makes. A first
  apply could still reveal a read call that is not covered.
- `CloudWatchFullAccess` already grants `logs:*` on all resources, so the log
  group needs no new permission, although that is broader than ideal. It is
  existing and unchanged.
- The Lambda execution role grants no `logs:CreateLogGroup` because the log
  group is Terraform-managed.

## Lambda role permissions

- `ecs:DescribeServices` on the `payments-api` service ARN only.
- `logs:CreateLogStream` and `logs:PutLogEvents` on its own log group only.
- No `ecs:Update*`, `ecs:RunTask`, `iam:PassRole`, or wildcards.

## Tests

```bash
make test-lambda
```
