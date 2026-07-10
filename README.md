# AI-Assisted Terraform Operations

[![CI](https://github.com/DuvalKingJacob/ai-infra-copilot/actions/workflows/ci.yml/badge.svg)](https://github.com/DuvalKingJacob/ai-infra-copilot/actions/workflows/ci.yml)

Terraform-native plan review with policy signals, authorization boundaries, agent workflows, approval gates, and auditability for platform teams adopting HCP Terraform or Terraform Enterprise.

This project explores a practical question for platform engineers:

> If an AI assistant can inspect Terraform run context and call operational tools, how should it fit into the governance model teams already use for policy, approval, state, and audit?

The answer here is intentionally conservative: the assistant can summarize plans, identify risky changes, retrieve authorized context, and propose next steps. It does not apply Terraform or bypass the HCP Terraform/TFE run lifecycle.

Engineers should not have to manually inspect hundreds of lines of Terraform plan output without help. This repo shows how an assistant can summarize infrastructure changes, identify risky modifications, and produce a review artifact while keeping humans in control of deployment decisions.

## Fastest Real Terraform Path

If you have AWS credentials and provider access, start with a real Terraform plan using the safe defaults:

```bash
make validate
make terraform-live-init
make terraform-live-review
open outputs/live-app-platform-plan-review-report.md
```

This runs Terraform against the app-platform scenario, exports the plan with `terraform show -json`, reviews the generated plan JSON, and opens the report. With safe defaults, the expected recommendation is `allow_plan_with_review`.

To demonstrate a risky real Terraform plan without applying anything:

```bash
make terraform-live-risky-review
open outputs/live-risky-app-platform-plan-review-report.md
```

The risky plan-only path uses `terraform/app-platform/risky.tfvars.example` to propose internet-facing load balancing, reduced service capacity, and missing ownership tags. The expected recommendation is `block_apply_pending_review`.

Live plan artifacts are written under `outputs/live-*` and ignored by Git because Terraform plan JSON can include account, resource, or sensitive metadata.

No target runs `terraform apply`.

For a short guided version of the demo, see:

`docs/demo-walkthrough.md`

## 30-Second Fixture Path

If you do not have cloud credentials, run the same review flow against the included Terraform plan JSON fixture:

```bash
make validate
make report-app
open outputs/app-platform-plan-review-report.md
```

The fixture uses the same JSON shape as `terraform show -json`, so the review behavior is inspectable without AWS, provider downloads, or HCP Terraform access.

## CI Checks

GitHub Actions runs the non-cloud validation path on pushes and pull requests:

```bash
make ci
```

CI validates the demo browser script, Terraform formatting, fixture-based plan review/report generation, local authorization checks, agent workflow, and Sentinel policy formatting. It does not run live cloud plans and it never runs `terraform apply`.

## Stacks / HashiBank Path

The repo now includes a workspace-to-Stacks migration scenario shaped like a real platform stack:

```text
vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app
```

The local version stays provider-light so the architecture can be reviewed without cloud credentials. The advanced path maps the same story to a HashiBank-style HCP Terraform / AWS / Kubernetes implementation.

Start here:

- `docs/stacks-prep-roadmap.md`: what the Stacks deep dive is building toward.
- `docs/terraform-video-companion-roadmap.md`: companion walkthrough plan for the Terraform video series.
- `docs/building-your-first-terraform-stack-walkthrough.md`: first Stacks companion walkthrough.
- `docs/terraform-practitioner-backlog.md`: working backlog for practitioner education topics.
- `terraform/workspace-to-stacks/README.md`: local migration scenario.
- `terraform/workspace-to-stacks/component-graph.md`: component dependency graph.
- `docs/stacks-live-prerequisites.md`: tools and access needed before recording a live HCP Terraform / HashiBank demo.
- `docs/stacks-video-validation-checklist.md`: product, narrative, and demo readiness checklist.
- `docs/hashibank-stacks-companion.md`: how the companion repo should relate to this reference architecture.

## What This Is

This is a local, inspectable reference implementation for AI-assisted Terraform workflows. The local demo keeps every moving part visible, while the production pattern maps to HCP Terraform/TFE runs, plans, policy checks, run tasks, approvals, variables, state, and audit logs.

It demonstrates:

- Terraform plan review over plan JSON.
- Markdown reports that could be attached to a pull request, run review, run task, or approval workflow.
- Sentinel-style policy findings for unsafe changes.
- SpiceDB/AuthZed authorization checks before context or tool output is exposed.
- MCP-style Terraform and Kubernetes tool access.
- A deterministic agent workflow that stops at proposal and approval.
- A workspace-to-Stacks migration scenario for VPC, EKS, and app components.

The goal is not to show off every AI framework. The goal is to make the Terraform operational control points visible.

## Demo Paths

Detailed commands for the Terraform-native workflow, browser demo, SpiceDB/AuthZed path, MCP gateway, plan reviewer, and agent workflow live in:

`docs/demo-paths.md`

## Why This Exists

Most AI demos stop at chat.

Infrastructure teams need something different. A useful platform assistant needs to answer questions from trusted internal context, inspect operational systems, reason about risk, and propose actions without silently bypassing the controls teams already depend on.

This demo explores one core idea:

> Once an AI assistant can retrieve internal context and call operational tools, authorization becomes part of the product architecture.

For the broader positioning, see:

`docs/reference-architecture-positioning.md`

## Implementation Tracks

This repo has three layers:

1. A local browser demo in `demo/index.html`.
2. Terraform-native CLI workflows for plan review, reports, policy examples, and agent execution.
3. Production-shaped integration scaffolding for authorization, MCP, OIDC, HCP Terraform, and Stacks.

The integration scaffolding includes:

- `data/`: source docs, users, and tool definitions.
- `src/`: optional embedding and permission-aware retrieval scripts.
- `spicedb/`: SpiceDB/AuthZed schema and relationship model.
- `mcp/`: official Terraform MCP Server example config.
- `terraform/`: Terraform scenarios for plan review, app-platform risk, and workspace-to-Stacks migration.
- `policies/sentinel/`: Sentinel-style policy examples.
- `docs/terraform-mcp-integration.md`: Terraform MCP integration plan.
- `docs/oidc-authentication-plan.md`: real authentication plan.
- `docs/demo-paths.md`: runnable demo commands.
- `docs/production-milestones.md`: honest roadmap from demo to production-shaped system.
- `docs/stacks-prep-roadmap.md`: Stacks deep-dive roadmap.
- `docs/terraform-video-companion-roadmap.md`: Terraform series companion roadmap.
- `docs/terraform-practitioner-backlog.md`: working content backlog.
- `docs/stacks-live-prerequisites.md`: live HashiBank / HCP Terraform prerequisites.

## Architecture Overview

For the product scenario, demo personas, architecture diagram, RAG/MCP rationale, security model, and production roadmap, see:

`docs/architecture-overview.md`

## Core Takeaway

AI-assisted infrastructure workflows are not just model problems. They are also authorization, context, tool-use, governance, and operational trust problems.
