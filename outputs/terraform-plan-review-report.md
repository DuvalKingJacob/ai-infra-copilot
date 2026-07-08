# Terraform Plan Review Report

## Summary

- Workspace: `prod-network`
- Run: `run-prod-network-2026-07-07`
- Terraform version: `1.9.8`
- Resources changed: 3
- Creates: 0
- Updates: 2
- Deletes: 1
- Replacements: 0
- Recommendation: `block_apply_pending_review`

## Risk Findings

| Severity | Policy | Resource | Action | Finding |
| --- | --- | --- | --- | --- |
| critical | no-public-ingress | `aws_security_group.payments_ingress` | update | Introduces public ingress with 0.0.0.0/0. |
| critical | no-wildcard-iam | `aws_iam_policy.deploy_bot` | update | Introduces wildcard IAM permissions or resources. |
| high | no-prod-monitoring-delete | `aws_cloudwatch_metric_alarm.payments_latency` | delete | Deletes monitoring or alerting resource during a production change. |
| medium | review-prod-destroy | `aws_cloudwatch_metric_alarm.payments_latency` | delete | Deletes infrastructure; confirm rollback and owner approval. |

## Policy Checks

These are Sentinel-style policy checks represented locally for the demo. In a production Terraform Enterprise workflow, these controls would run in the policy phase.

| Policy | Decision |
| --- | --- |
| `no-internet-facing-lb` | pass |
| `no-public-ingress` | fail |
| `no-wildcard-iam` | fail |
| `no-prod-db-replacement` | pass |
| `require-db-deletion-protection` | pass |
| `minimum-prod-service-capacity` | pass |
| `no-prod-monitoring-delete` | fail |
| `require-prod-tags` | pass |
| `review-prod-replacement` | pass |
| `review-prod-destroy` | fail |

## Blast Radius

- Network exposure: public ingress can expose a production service to the internet.
- Identity blast radius: wildcard IAM can expand what the deployment identity can do.
- Observability risk: deleting monitoring reduces visibility during or after the change.
- Operational risk: deleted resources require owner approval and rollback review.

## Approval Required

Yes. A human reviewer should approve or reject this plan before apply.

## What The Agent Did Not Do

- It did not run `terraform apply`.
- It did not mutate cloud infrastructure.
- It did not bypass Terraform policy checks.
- It did not bypass authorization to inspect production context.
- It produced an explainable review artifact for a human-controlled workflow.

## Architecture Note

SpiceDB/AuthZed answers whether the actor is allowed to access the plan review capability. Sentinel-style policy answers whether the Terraform change itself is acceptable.
