# Production Network Terraform Sample

This is a small Terraform configuration used by the demo's plan-review workflow.

It intentionally models a risky production change so the AI infrastructure copilot can review and explain the blast radius before anything is applied.

## What It Contains

- A payments ingress security group.
- A deploy-bot IAM policy.
- A CloudWatch latency alarm.

## Safe Defaults

The default variables are intentionally conservative:

- ingress CIDR is limited to an internal network.
- IAM policy is scoped to one ECS service.
- latency alarm is enabled.

## Risky Review Scenario

The demo plan JSON in `data/terraform-plan.prod-network.json` represents a risky proposed change:

- public ingress via `0.0.0.0/0`
- wildcard IAM permissions
- monitoring alarm deletion

Those are the exact findings produced by:

```bash
make review
make report
```

## Why This Exists

The point is not to deploy AWS resources from this repo. The point is to make the Terraform review scenario concrete enough for platform engineering audiences:

- plan
- inspect blast radius
- explain risk
- require authorization
- require approval
- avoid direct agent-driven apply

## Validation

Format:

```bash
terraform -chdir=terraform/prod-network fmt
```

Validate:

```bash
terraform -chdir=terraform/prod-network init -backend=false
terraform -chdir=terraform/prod-network validate
```

Validation requires access to `registry.terraform.io` so Terraform can install the AWS provider.
