# Terraform AI Learning Roadmap

This roadmap keeps the project useful for Terraform and platform engineering learning.

## Goal

Explore AI-assisted infrastructure workflows through Terraform, MCP-style tools, RAG, authorization, approval, and auditability.

The focus is not autonomous infrastructure mutation. The focus is safe assistance:

- inspect
- retrieve
- explain
- review
- propose
- require approval
- audit

Future ideas that should not derail the current demo live in:

```text
docs/ai-repo-backlog.md
```

## Track 1: Terraform Plan Review

Current state:

- Real Terraform sample in `terraform/prod-network`.
- Sample risky plan in `data/terraform-plan.prod-network.json`.
- Plan reviewer in `src/review-terraform-plan.mjs`.

Next ideas:

- Compare AI-style findings with Sentinel or OPA policies.
- Add severity categories for networking, IAM, observability, data stores, and deletion.
- Generate a human-readable review summary from the structured findings.
- Add a pull-request style Markdown report.

Next build:

1. Add `src/render-plan-review-report.mjs`.
2. Generate `outputs/terraform-plan-review.md` from the JSON findings.
3. Include sections for blast radius, risky resources, approval recommendation, and rollback considerations.
4. Compare the generated review against one or two policy-as-code checks.

Deliverable:

- A Markdown plan review that looks like something a platform team could paste into a pull request or run record.

## Track 2: HCP Terraform / Terraform Cloud Workflow Mapping

Questions to explore:

- Where should an AI reviewer run: local CLI, pull request, run task, or workspace event?
- What workspace data is safe to retrieve as agent context?
- Which outputs, variables, and run metadata should be redacted?
- How should approval hand off to existing Terraform Cloud workflows?

Safe target:

> AI reviews and explains a plan, but does not apply it.

Next build:

1. Add a workflow diagram for where an AI reviewer could sit: pull request, local CLI, run task, workspace event, or incident workflow.
2. Define the minimum safe metadata that tools may retrieve for the agent.
3. Define sensitive fields that should be redacted before model exposure.
4. Map approval handoff to existing Terraform Cloud run approval concepts.

Deliverable:

- `docs/hcp-terraform-ai-workflow.md`

Suggested thesis:

> AI review should complement Terraform's existing workflow rather than bypass it.

## Track 3: Terraform MCP

Current state:

- MCP-style authorization gateway exists in `src/tool-call.mjs`.
- Official Terraform MCP config exists in `mcp/terraform-mcp.example.json`.

Next ideas:

- Connect read-only Terraform Registry queries.
- Connect read-only workspace inspection.
- Keep variables, outputs, and run details behind explicit authorization.
- Log every MCP tool request and authorization decision.

Design principle:

> MCP exposes infrastructure capabilities; authorization decides which actor can use them.

Next build:

1. Add a read-only MCP adapter for the local Terraform sample.
2. Expose tools such as `terraform.list_workspaces`, `terraform.get_plan_summary`, and `terraform.review_plan`.
3. Keep the existing authorization gateway in front of every tool.
4. Document how the adapter would be replaced by the official Terraform MCP Server.

Deliverable:

- A real local MCP server or MCP-shaped adapter that returns Terraform plan/workspace context only after authorization.

## Track 4: Permission-Aware RAG For Infrastructure Docs

Current state:

- Docs are retrieved and filtered before becoming model-visible context.
- SpiceDB can back the document authorization checks.

Next ideas:

- Add Terraform module docs.
- Add runbooks for workspace failure modes.
- Add incident/postmortem examples.
- Add chunk-level permissions.
- Add hybrid retrieval.

Design principle:

> Retrieved context is data access. Treat it like a protected resource.

Next build:

1. Add Terraform module docs and workspace runbooks to `data/docs.json`.
2. Split docs into chunks with individual permissions.
3. Generate embeddings per chunk.
4. Keep SpiceDB checks before context assembly.

Deliverable:

- A RAG query where Alice can retrieve production Terraform context and Bob gets only support/customer-safe context.

## Track 5: Agentic Workflow Boundaries

Current state:

- `src/agent-workflow.mjs` plans, retrieves, checks authorization, calls tools, reviews risk, proposes action, and emits audit output.

Next ideas:

- Add approval state as a persistent object.
- Add a dry-run remediation workflow.
- Add a Markdown incident summary.
- Add memory only after retention and authorization rules are explicit.

Design principle:

> The agent can summarize authorized context and propose; production mutation belongs in controlled workflows.

Next build:

1. Add persistent proposal state as JSON.
2. Model proposal creation and approval as separate authorization checks.
3. Add an `approval:record` command.
4. Emit an audit event showing who proposed, who approved, and what remained blocked.

Deliverable:

- A full inspect -> review -> propose -> approve -> audit flow with no direct apply.

## 30-Day Learning Plan

### Week 1: Make Terraform Review Useful

- Generate Markdown reports from plan findings.
- Add one or two policy-as-code comparisons.
- Document where AI review is helpful and where hard policy should win.

### Week 2: Make Tool Access More Real

- Build a local MCP-style adapter for Terraform plan/workspace context.
- Keep SpiceDB authorization in front of every tool call.
- Document the path to the official Terraform MCP Server.

### Week 3: Improve RAG Quality

- Add Terraform module docs, workspace runbooks, and incident notes.
- Add chunk-level permissions.
- Compare keyword, local embedding, and API embedding retrieval behavior.

### Week 4: Tighten Agent Governance

- Add persistent proposal state.
- Add approval recording.
- Add audit event output.
- Write a short technical article from the work.

## Content Ideas

- AI agents should review Terraform plans, not apply them.
- MCP makes Terraform accessible to agents; authorization makes it safe enough to use.
- RAG over infrastructure docs is a permissions problem before it is a retrieval problem.
- Terraform plan review is a useful proving ground for AI governance.
- What platform teams should log when an AI assistant uses infrastructure tools.

## Useful Questions For Content

- What should an AI agent be allowed to see in a Terraform workspace?
- Should Terraform outputs be model-visible by default?
- How should teams authorize MCP tool calls?
- What is the difference between plan review, policy-as-code, and agentic remediation?
- Where should human approval sit in AI-assisted infrastructure workflows?
- What should be audited: prompt, retrieved context, tool call, policy decision, or all of them?
