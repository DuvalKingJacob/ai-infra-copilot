# Three-Minute Demo Walkthrough

This walkthrough is the fastest way to understand the project without reading the full architecture notes.

## The Point

AI should help practitioners review Terraform plans inside the governance model they already trust. It should not bypass Terraform runs, policy checks, approval gates, authorization, or audit.

The demo shows three things:

1. Terraform creates the plan.
2. The reviewer explains risk from Terraform plan JSON.
3. The agent stops at review and proposal. It does not apply.

## Prerequisites

For the live path:

- Terraform installed.
- AWS credentials available.
- Provider downloads allowed.

For the fixture path, no cloud access is required.

## Path A: Real Terraform Plan

Use this when demoing from a machine with Terraform and AWS access.

```bash
make validate
make terraform-live-init
make terraform-live-risky-review
open outputs/live-risky-app-platform-plan-review-report.md
```

What to point out:

- Terraform runs `plan`, not the agent.
- The plan is exported with `terraform show -json`.
- The reviewer flags an internet-facing load balancer, low service capacity, and missing ownership tags.
- The recommendation is `block_apply_pending_review`.
- The report explicitly says no `terraform apply` was run.

## Path B: Fixture Demo

Use this when demoing from a clean machine or CI-like environment.

```bash
make validate
make report-app
open outputs/app-platform-plan-review-report.md
```

What to point out:

- The fixture uses the same JSON shape as `terraform show -json`.
- The app-platform plan includes network, service, database, monitoring, and tagging risk.
- This keeps the demo runnable without cloud credentials.

## Authorization Check

Show that tool access is gated before plan context reaches the agent:

```bash
make tool-check-local
```

What to point out:

- Alice can call the Terraform plan review capability.
- Bob cannot.
- Denied tool output is not returned to the model.

## Agent Boundary

Show the agent workflow:

```bash
make agent
```

What to point out:

- The agent retrieves allowed context.
- It calls authorized tools.
- It reviews Terraform risk.
- It proposes next steps.
- `mutationExecuted` is `false`.

## Talk Track

Use this framing:

> This is not a demo where an agent applies Terraform. Terraform owns the plan. HCP Terraform or Terraform Enterprise would own the production run, policy checks, approvals, state, and audit. The agent reviews authorized Terraform context and produces an explainable artifact for a human-controlled workflow.

## Production Mapping

| Local demo | Production analogue |
| --- | --- |
| Terraform CLI plan | HCP Terraform/TFE run |
| `terraform show -json` | plan JSON / run context |
| Sentinel-style local policies | Sentinel/OPA policy checks |
| `make tool-check-local` | authorization before tool/context access |
| Markdown review report | run task, PR comment, Slack summary, or approval note |
| no apply target | human approval and controlled Terraform apply |

## Do Not Demo

- Do not run `terraform apply`.
- Do not commit `outputs/live-*`.
- Do not present the agent as the deployment authority.
- Do not make SpiceDB/AuthZed sound like Terraform policy. It is authorization around AI context and tool access.
