# Teleprompter: AI Should Review Terraform Plans, Not Apply Them

Target length: 5-7 minutes

## Setup

Open the repo in a terminal.

Have this report ready to open after the command finishes:

```bash
outputs/live-risky-app-platform-plan-review-report.md
```

## 0:00 - Hook

AI can write Terraform now.

That is useful, but it is not the part of the workflow I care about most.

The bigger question is:

How should AI fit into a real Terraform run?

If a platform team already depends on HCP Terraform or Terraform Enterprise for plans, policy checks, approvals, variables, state, and audit logs, I do not want an agent bypassing that control plane.

The safer pattern is:

AI reviews the plan.

Terraform owns the run.

Humans still approve production-impacting changes.

## 0:45 - Show The Project

Show the README title:

```text
AI-Assisted Terraform Operations
```

Say:

This repo is a small reference implementation of that pattern.

It is not trying to prove that an agent can replace Terraform.

It is trying to prove that an agent can help practitioners understand Terraform risk before anything applies.

The local demo maps to a production pattern:

```text
HCP Terraform / TFE run
  -> Terraform plan
  -> policy checks
  -> AI-assisted review
  -> human approval
  -> controlled apply
  -> audit trail
```

## 1:30 - Run The Real Terraform Path

Run:

```bash
make validate
make terraform-live-init
make terraform-live-risky-review
```

Say while it runs:

This is a real Terraform plan path.

Terraform is running `plan`.

Then the plan is exported with `terraform show -json`.

The reviewer consumes that Terraform-generated JSON and writes a review report.

The agent is not running apply.

The reviewer is not mutating infrastructure.

This is review before approval.

## 2:30 - Open The Report

Run:

```bash
open outputs/live-risky-app-platform-plan-review-report.md
```

Point to the summary.

Say:

The recommendation is `block_apply_pending_review`.

That is the key outcome. The assistant is not making the final deployment decision, but it is producing a clear signal for the human review process.

Point to the findings.

Say:

This plan creates an internet-facing load balancer.

It creates a production service with desired count one.

It is missing required ownership and environment tags.

Those are exactly the kinds of things platform engineers and SREs look for during review, but they can be easy to miss in a large plan.

## 3:30 - Explain The Governance Model

Say:

This is where the HashiCorp story matters.

In production, I would not want this to be a separate deployment system.

I would want HCP Terraform or Terraform Enterprise to remain the system of record for:

- runs
- plans
- policy checks
- variables
- state
- approvals
- audit logs

The AI review should attach to that workflow.

It could become a run task result, a pull request comment, a Slack approval summary, or a companion view next to the plan.

But the governed Terraform workflow should still own apply.

## 4:15 - Policy Versus Authorization

Show:

```text
policies/sentinel
spicedb/schema.zed
```

Say:

There are two different control questions here.

Policy asks:

Is this Terraform change acceptable?

That is where Sentinel, OPA, policy checks, and run tasks fit.

Authorization asks:

Is this actor allowed to inspect this run, retrieve this context, or call this tool?

That is where something like SpiceDB or AuthZed fits.

The model should not see production context just because someone asked nicely in a prompt.

## 5:00 - Show Authorization Boundary

Run:

```bash
make tool-check-local
```

Say:

This is intentionally simple.

Alice can call the Terraform plan review capability.

Bob cannot.

The important part is that denied tool output never becomes model context.

That matters once you start exposing tools through MCP or internal platform APIs.

MCP can make tools available to agents, but authorization still decides which actor can use which tool against which workspace, run, Stack, or environment.

## 5:45 - Show Agent Boundary

Run:

```bash
make agent
```

Say:

This ties the pieces together.

The agent retrieves allowed context, calls authorized tools, reviews Terraform risk, and proposes next steps.

But the boundary is explicit.

Point to:

```text
mutationExecuted: false
proposal.status: requires_human_approval
```

Say:

That is the design choice.

The agent can answer, review, and propose.

It does not apply.

## 6:30 - Close

Say:

The goal is not to hand production to an agent.

The goal is to make the agent a better reviewer inside the Terraform governance model the platform already trusts.

Terraform plans remain the control point.

HCP Terraform and Terraform Enterprise remain the system of record.

Policy evaluates the change.

Authorization controls what context and tools the agent can access.

Human approval controls whether anything proceeds.

That is the pattern I want from AI-assisted Terraform operations:

helpful,

explainable,

authorized,

policy-aware,

and still human-controlled where it matters.

## Backup Commands

If the live Terraform path is not available:

```bash
make validate
make report-app
open outputs/app-platform-plan-review-report.md
```

If Sentinel is available:

```bash
make sentinel-check
```

If SpiceDB is running:

```bash
make tool-check
```

If SpiceDB is not running:

```bash
make tool-check-local
```
