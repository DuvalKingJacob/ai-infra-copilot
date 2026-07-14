# AI Repo Backlog

This backlog captures future ideas without turning every good conversation into immediate implementation.

The project should stay focused on one practitioner thesis:

> AI can help platform teams inspect, explain, classify, and propose infrastructure actions, but HCP Terraform or Terraform Enterprise should remain the control point for execution, approvals, state, policy, and audit.

## How To Use This Backlog

- Treat these as future issue candidates, not commitments.
- Prefer demos that start with real Terraform practitioner pain.
- Keep internal roadmap details out of public docs.
- Do not add autonomous apply behavior just to make the demo feel more agentic.

## Backlog Items

### AI-Assisted Drift Triage

Status:

```text
scaffolded with sample drift events and a Markdown report
```

Problem:

Large Terraform estates can produce more drift events than a platform team can manually triage.

Demo idea:

- Ingest a sample set of drift events.
- Classify drift as cosmetic, configuration, security, critical production, or needs investigation.
- Enrich each event with workspace, project, owner, environment, resource type, previous run, and policy context.
- Generate a prioritized Markdown report for human review.

Current command:

```bash
make drift-report
open outputs/drift-triage-report.md
```

Why it matters:

- Shows AI solving a real operational scale problem.
- Connects drift detection to Terraform governance instead of auto-remediation.
- Reuses the current inspect, classify, propose, approve pattern.

Non-goal:

- Do not build an autonomous drift fixer.

### Explorer-Style Context Enrichment

Problem:

Plan review and drift review are more useful when the agent understands dependency and ownership context.

Demo idea:

- Add fixture data that models dependency context across workspaces, components, resources, and owners.
- Let the agent include blast-radius notes such as downstream services, shared networks, and owner teams.
- Keep the fixture public-safe and avoid claims about unreleased product behavior.

Why it matters:

- Makes the agent feel like an infrastructure assistant, not a generic summarizer.
- Connects Terraform context to practitioner questions such as "what depends on this?" and "who owns this?"

### `tfctl` Integration Improvements

Problem:

The current `tfctl` bridge works, but the output is still raw and demo-oriented.

Demo idea:

- Normalize `tfctl` output into structured fields.
- Improve handling for no current run, errored plan, and empty variables.
- Redact sensitive variable keys or mark them clearly before model exposure.
- Make the displayed command strings less visually confusing when `--jq` expressions contain pipes.

Why it matters:

- Makes the HCP Terraform context path easier to explain on video.
- Reinforces that agents should consume curated context, not raw operational output.

### Run Task Companion Demo

Problem:

Practitioners need to understand where AI review could sit in the HCP Terraform/TFE run lifecycle.

Demo idea:

- Create a public-safe conceptual walkthrough showing AI review as a run-adjacent control.
- Compare local plan review, pull request review, run task, and post-run audit patterns.
- Show which concerns belong to policy checks versus advisory AI review.

Why it matters:

- Helps position AI as additive to existing governance.
- Connects plan review to adoption of HCP Terraform/TFE workflows.

### MCP And Skills Examples

Problem:

MCP can sound abstract unless the demo shows exactly what capabilities are exposed and who may call them.

Demo idea:

- Add examples for read-only tools such as registry lookup, workspace metadata lookup, plan summary, and policy summary.
- Keep authorization in front of each tool.
- Document which tool calls are safe, sensitive, or intentionally blocked.

Why it matters:

- Makes MCP concrete for infrastructure audiences.
- Keeps the security story centered on tool authorization and context boundaries.

### Future Managed Agent Concepts

Problem:

Agentic workflows can become vague unless they are grounded in specific operational jobs.

Demo idea:

- Document concept cards for agents such as plan reviewer, drift triage assistant, policy explanation assistant, and migration planning assistant.
- For each concept, define inputs, allowed context, prohibited actions, approval boundary, and audit output.

Why it matters:

- Gives the repo a reusable way to evaluate future agent ideas.
- Keeps the architecture focused on workflows rather than model hype.

## Prioritization

Near term:

1. Improve the existing `tfctl` demo output.
2. Finish the AI plan review walkthrough.
3. Expand the drift triage fixture only after the basic report is validated with the video storyline.

Later:

1. Add MCP examples that map cleanly to Terraform practitioner tasks.
2. Explore run task positioning.
3. Turn drift triage into a dedicated companion demo.
