# Application Platform Terraform Sample

This scenario is a richer SRE-style review target for the Terraform-native demo.

It models a production application platform with:

- an internal application load balancer
- an ECS cluster and service
- a primary PostgreSQL database
- a latency alarm
- required production tags

## Risky Review Scenario

The sample plan JSON in `data/terraform-plan.app-platform.json` represents a risky proposed change:

- an internal load balancer becoming internet-facing
- a production database replacement
- ECS desired count dropping from 6 to 1
- latency alarm deletion
- missing required tags

If you have AWS credentials and provider access, generate and review a live plan:

```bash
make terraform-live-init
make terraform-live-review
open outputs/live-app-platform-plan-review-report.md
```

For a credential-free fixture review:

```bash
make review-app
make report-app
open outputs/app-platform-plan-review-report.md
```

## Why This Exists

The original `prod-network` scenario is intentionally small. This scenario feels closer to a platform/SRE review because it includes availability, data, security, and operability concerns in one plan.
