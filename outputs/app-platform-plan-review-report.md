# Terraform Plan Review Report

## Summary

- Workspace: `app-platform-prod`
- Run: `run-app-platform-2026-07-08`
- Terraform version: `1.9.8`
- Resources changed: 4
- Creates: 1
- Updates: 2
- Deletes: 2
- Replacements: 1
- Recommendation: `block_apply_pending_review`

## Risk Findings

| Severity | Policy | Resource | Action | Finding |
| --- | --- | --- | --- | --- |
| critical | no-internet-facing-lb | `aws_lb.api` | update | Changes an internal load balancer to internet-facing. |
| medium | require-prod-tags | `aws_lb.api` | update | Missing required production tags: Environment, Owner. |
| high | review-prod-replacement | `aws_db_instance.primary` | delete, create | Replaces infrastructure; confirm downtime, data safety, and rollback plan. |
| critical | no-prod-db-replacement | `aws_db_instance.primary` | delete, create | Replaces a production database instance. |
| high | require-db-deletion-protection | `aws_db_instance.primary` | delete, create | Disables deletion protection on a database. |
| medium | require-prod-tags | `aws_db_instance.primary` | delete, create | Missing required production tags: Environment, Owner. |
| medium | review-prod-destroy | `aws_db_instance.primary` | delete, create | Deletes infrastructure; confirm rollback and owner approval. |
| high | minimum-prod-service-capacity | `aws_ecs_service.api` | update | Reduces service desired count from 6 to 1. |
| medium | require-prod-tags | `aws_ecs_service.api` | update | Missing required production tags: Owner. |
| high | no-prod-monitoring-delete | `aws_cloudwatch_metric_alarm.api_latency` | delete | Deletes monitoring or alerting resource during a production change. |
| medium | review-prod-destroy | `aws_cloudwatch_metric_alarm.api_latency` | delete | Deletes infrastructure; confirm rollback and owner approval. |

## Policy Checks

These are Sentinel-style policy checks represented locally for the demo. In a production Terraform Enterprise workflow, these controls would run in the policy phase.

| Policy | Decision |
| --- | --- |
| `no-internet-facing-lb` | fail |
| `no-public-ingress` | pass |
| `no-wildcard-iam` | pass |
| `no-prod-db-replacement` | fail |
| `require-db-deletion-protection` | fail |
| `minimum-prod-service-capacity` | fail |
| `no-prod-monitoring-delete` | fail |
| `require-prod-tags` | fail |
| `review-prod-replacement` | fail |
| `review-prod-destroy` | fail |

## Blast Radius

- Network exposure: an internal service boundary may become internet-facing.
- Governance risk: missing tags weaken ownership, cost, and incident routing.
- Operational risk: replacement requires downtime and rollback review.
- Data-plane risk: replacing a production database can cause data loss or downtime.
- Data safety risk: disabling deletion protection makes destructive database changes easier.
- Operational risk: deleted resources require owner approval and rollback review.
- Availability risk: reducing service capacity can degrade or interrupt production traffic.
- Observability risk: deleting monitoring reduces visibility during or after the change.

## Approval Required

Yes. A human reviewer should approve or reject this plan before apply.

## What The Agent Did Not Do

- It did not run `terraform apply`.
- It did not mutate cloud infrastructure.
- It did not bypass Terraform policy checks.
- It did not bypass authorization to retrieve production context.
- It produced an explainable review artifact for a human-controlled workflow.

## Architecture Note

Authorization answers whether the actor is allowed to access the plan review capability. Sentinel-style policy answers whether the Terraform change itself is acceptable.
