# Terraform AI Learning Roadmap

This roadmap keeps the project useful for Terraform and platform engineering learning.

## Goal

Explore AI-native infrastructure workflows through Terraform, MCP-style tools, RAG, authorization, approval, and auditability.

The focus is not autonomous infrastructure mutation. The focus is safe assistance:

- inspect
- retrieve
- explain
- review
- propose
- require approval
- audit

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

## Track 2: HCP Terraform / Terraform Cloud Workflow Mapping

Questions to explore:

- Where should an AI reviewer run: local CLI, pull request, run task, or workspace event?
- What workspace data is safe for an agent to inspect?
- Which outputs, variables, and run metadata should be redacted?
- How should approval hand off to existing Terraform Cloud workflows?

Safe target:

> AI reviews and explains a plan, but does not apply it.

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

## Track 5: Agentic Workflow Boundaries

Current state:

- `src/agent-workflow.mjs` plans, retrieves, checks authorization, calls tools, reviews risk, proposes action, and emits audit output.

Next ideas:

- Add approval state as a persistent object.
- Add a dry-run remediation workflow.
- Add a Markdown incident summary.
- Add memory only after retention and authorization rules are explicit.

Design principle:

> The agent can inspect and propose; production mutation belongs in controlled workflows.

## Useful Questions For Content

- What should an AI agent be allowed to see in a Terraform workspace?
- Should Terraform outputs be model-visible by default?
- How should teams authorize MCP tool calls?
- What is the difference between plan review, policy-as-code, and agentic remediation?
- Where should human approval sit in AI-assisted infrastructure workflows?
- What should be audited: prompt, retrieved context, tool call, policy decision, or all of them?

