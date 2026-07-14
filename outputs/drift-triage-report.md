# AI-Assisted Drift Triage Report

## Summary

- Source: `sample-hcp-terraform-drift-detection`
- Generated at: `2026-07-14T13:00:00Z`
- Drift events reviewed: 6
- Approval required: Yes

## Severity Queue

- critical: 2
- high: 3
- medium: 0
- low: 1
- informational: 0

## Prioritized Findings

| Severity | Workspace | Resource | Category | Recommendation | Owner |
| --- | --- | --- | --- | --- | --- |
| critical | `payments-network-prod` | `aws_security_group.payments_ingress` | security_drift | escalate_to_security_and_block_auto_remediation | network-platform |
| critical | `identity-prod` | `aws_iam_policy.deploy_bot` | security_drift | escalate_to_security_and_block_auto_remediation | security-platform |
| high | `app-platform-prod` | `aws_ecs_service.api` | availability_drift | investigate_incident_context_before_remediation | app-platform |
| high | `shared-data-prod` | `aws_db_instance.primary` | data_safety_drift | open_remediation_plan_pending_owner_approval | data-platform |
| high | `observability-prod` | `aws_cloudwatch_metric_alarm.api_latency` | observability_drift | review_with_service_owner | sre |
| low | `billing-dev` | `aws_s3_bucket.logs` | governance_drift | review_or_reconcile_in_code | billing-team |

## Findings Detail

### drift-001: aws_security_group.payments_ingress

- Workspace: `payments-network-prod`
- Project: `payments`
- Environment: `prod`
- Owner: `network-platform`
- Severity: `critical`
- Category: `security_drift`
- Recommendation: `escalate_to_security_and_block_auto_remediation`
- Reason: Public exposure appeared outside the declared Terraform configuration.
- Summary: Manual console change added public ingress to the payments service security group.
- Last run status: `applied`
- Last policy result: `passed`

### drift-006: aws_iam_policy.deploy_bot

- Workspace: `identity-prod`
- Project: `security`
- Environment: `prod`
- Owner: `security-platform`
- Severity: `critical`
- Category: `security_drift`
- Recommendation: `escalate_to_security_and_block_auto_remediation`
- Reason: Identity permissions expanded outside Terraform review.
- Summary: IAM policy now includes wildcard actions outside Terraform.
- Last run status: `applied`
- Last policy result: `passed`

### drift-002: aws_ecs_service.api

- Workspace: `app-platform-prod`
- Project: `platform`
- Environment: `prod`
- Owner: `app-platform`
- Severity: `high`
- Category: `availability_drift`
- Recommendation: `investigate_incident_context_before_remediation`
- Reason: Production capacity changed outside the normal Terraform run workflow.
- Summary: Desired task count was reduced during an incident and has not been reconciled.
- Last run status: `applied`
- Last policy result: `passed`
- Incident reference: `INC-204`

### drift-003: aws_db_instance.primary

- Workspace: `shared-data-prod`
- Project: `data-platform`
- Environment: `prod`
- Owner: `data-platform`
- Severity: `high`
- Category: `data_safety_drift`
- Recommendation: `open_remediation_plan_pending_owner_approval`
- Reason: A data safety control changed outside Terraform.
- Summary: Deletion protection was disabled outside Terraform.
- Last run status: `applied`
- Last policy result: `passed`

### drift-004: aws_cloudwatch_metric_alarm.api_latency

- Workspace: `observability-prod`
- Project: `platform`
- Environment: `prod`
- Owner: `sre`
- Severity: `high`
- Category: `observability_drift`
- Recommendation: `review_with_service_owner`
- Reason: Monitoring behavior changed and may reduce incident visibility.
- Summary: Latency alarm threshold was changed manually during tuning.
- Last run status: `applied`
- Last policy result: `passed`

### drift-005: aws_s3_bucket.logs

- Workspace: `billing-dev`
- Project: `billing`
- Environment: `dev`
- Owner: `billing-team`
- Severity: `low`
- Category: `governance_drift`
- Recommendation: `review_or_reconcile_in_code`
- Reason: Tag drift affects ownership, cost, or routing metadata but is not immediately dangerous.
- Summary: Cost allocation tag was changed outside Terraform.
- Last run status: `applied`
- Last policy result: `passed`

## Recommended Operating Model

This report treats drift as a review workflow:

1. HCP Terraform or Terraform Enterprise detects that real infrastructure diverged from Terraform-managed state.
2. The assistant classifies and prioritizes the drift event using workspace, ownership, environment, run, and policy context.
3. A human decides whether to ignore, investigate, import, update code, plan remediation, or escalate.
4. Any infrastructure change goes back through Terraform runs, policy checks, approvals, state, and audit.

## What The Agent Did Not Do

- It did not run `terraform apply`.
- It did not mutate cloud infrastructure.
- It did not automatically remediate drift.
- It did not bypass HCP Terraform or Terraform Enterprise run governance.
- It produced an explainable triage artifact for human review.

## Architecture Note

Plan review and drift triage share the same operating boundary: AI can inspect, classify, explain, and propose, but Terraform remains the execution and audit control point.
