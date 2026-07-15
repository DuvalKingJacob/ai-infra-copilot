# Demo Paths

This document contains the detailed local commands that used to live in the README.

## Terraform-Native Hero Workflow

The primary workflow starts with Terraform creating the plan, then passes the plan JSON into the reviewer:

```bash
terraform -chdir=terraform/prod-network plan -out=tfplan
terraform -chdir=terraform/prod-network show -json tfplan > data/plan.json
make review PLAN=data/plan.json
make report PLAN=data/plan.json REPORT=outputs/terraform-plan-review-report.md
```

`make` is only the local demo wrapper for the review/report steps. Terraform still owns the infrastructure workflow: configuration, plan creation, plan JSON, and controlled apply. In HCP Terraform or Terraform Enterprise, the equivalent integration point would be the run, plan output, policy checks, run tasks, approvals, and audit trail.

The Makefile version of the same live workflow is:

```bash
make terraform-live-init
make terraform-live-plan
make terraform-live-export
make terraform-live-report
```

For the risky plan-only version:

```bash
make terraform-live-risky-review
```

For a local demo without cloud credentials, use the included sample plan:

```bash
make review
make report
```

That produces:

```text
outputs/terraform-plan-review-report.md
```

For a richer SRE-style application platform review:

```bash
make review-app
make report-app
```

The JavaScript is implementation detail. The practitioner story is Terraform run -> plan review -> policy signal -> approval boundary -> controlled apply.

## Browser Demo

Open the demo locally:

```text
demo/index.html
```

No install step is required.

## CLI Experiments

The static browser demo is the fastest walkthrough. The Terraform-native CLI path is the main practitioner demo.

If you are not a Node.js developer, start with:

```text
docs/local-validation-runbook.md
```

```bash
make validate
make review
make report
make review-app
make report-app
make agent
```

If `OPENAI_API_KEY` is set, `embeddings:build` uses the OpenAI embeddings API. Without it, the script uses a deterministic local embedding fallback so the project remains runnable without secrets.

## Optional External Authorization Path

The project includes an executable SpiceDB/AuthZed integration path as an optional example of external relationship-based authorization around AI context and tool access.

Start SpiceDB:

```bash
docker compose up -d spicedb
```

Load the schema and relationships:

```bash
npm run authz:validate
npm run authz:load
```

Check document access:

```bash
npm run authz:check -- alice document:postmortem-platform-204 read --provider=spicedb
npm run authz:check -- bob document:postmortem-platform-204 read --provider=spicedb
```

Use SpiceDB during RAG filtering:

```bash
npm run rag:query -- alice "What do we know about the production outage?" --provider=spicedb
```

The important production-shaped lesson is provider-agnostic: retrieved context should be filtered by authorization before it reaches the model.

## Terraform MCP Gateway Path

The repo includes a read-only gateway command that authorizes MCP-style tool calls before returning infrastructure data:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=local
npm run tool:call -- bob terraform.get_recent_changes --provider=local
```

With SpiceDB running and loaded:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=spicedb
```

The official Terraform MCP Server config lives at:

```text
mcp/terraform-mcp.example.json
```

The intended production shape is:

1. Actor asks for Terraform context.
2. Gateway checks whether the actor can call the requested tool.
3. Allowed read-only calls are routed to Terraform MCP.
4. Plans remain proposal-only.
5. Applies remain behind human approval and controlled workflow handoff.

## Terraform Plan Review

To tie the demo directly to Terraform practitioner work, the repo includes a small Terraform plan reviewer:

```bash
make review
make report
```

The real Terraform sample lives in:

```text
terraform/prod-network
```

A richer application platform scenario lives in:

```text
terraform/app-platform
```

A workspace-to-Stacks migration scenario lives in:

```text
terraform/workspace-to-stacks
```

The reviewer inspects `data/terraform-plan.prod-network.json`, which represents a risky proposed change against that Terraform shape, and flags:

- Public security group ingress.
- Wildcard IAM permissions.
- Monitoring deletion.

The report is written to:

```text
outputs/terraform-plan-review-report.md
```

The policy examples live in:

```text
policies/sentinel
```

Sentinel local setup notes live in:

```text
docs/sentinel-local-setup.md
```

HCP Terraform and Stacks planning notes live in:

```text
docs/hcp-terraform-stacks-plan.md
```

The Stacks deep-dive roadmap lives in:

```text
docs/stacks-prep-roadmap.md
```

Live HashiBank / HCP Terraform prerequisites live in:

```text
docs/stacks-live-prerequisites.md
```

The richer HashiBank Stacks companion scenario is documented at:

```text
docs/hashibank-stacks-companion.md
```

The point is not to replace policy-as-code. The point is to show how an AI-native workflow can explain infrastructure risk, require authorization before production plan context reaches the agent, surface Sentinel-style policy signals, and keep apply behind human approval.

Authorization and Sentinel-style policy sit at different layers:

- Authorization: is this actor allowed to retrieve this plan context or call this tool?
- Sentinel-style policy: is this Terraform change acceptable?

See:

```text
docs/terraform-plan-review.md
```

## Agent Workflow

The repo includes a small deterministic agent runner:

```bash
make agent
```

With optional read-only `tfctl` context:

```bash
make agent-tfctl
TFCTL_WORKSPACE=WORKSPACE_NAME make agent-tfctl
```

With SpiceDB running:

```bash
node src/agent-workflow.mjs alice "Should we apply the Terraform change?" --provider=spicedb
node src/agent-workflow.mjs bob "Should we apply the Terraform change?" --provider=spicedb
```

It demonstrates planning, permission-aware retrieval, authorized tool calls, Terraform risk review, action proposal, approval boundary, and audit output.

See:

```text
docs/agent-workflow.md
```

## Terraform AI Learning Roadmap

This repo is also a way to explore AI-assisted Terraform workflows without treating agents as production operators.

See:

```text
docs/terraform-ai-learning-roadmap.md
```
