# Architecture Decisions

## Decision 1: Start Local

The project starts as a local, browser-openable demo so the workflow is easy to inspect and share. This avoids cloud credentials, account setup, and production risk while still making the architecture visible.

Production extension:

- Add OIDC authentication.
- Add persistent backend services.
- Add real Terraform and Kubernetes integrations.

## Decision 2: Use MCP-Style Tools

MCP-style tools make infrastructure capabilities explicit. The assistant calls named tools such as Terraform change inspection and Kubernetes service status instead of hiding those capabilities in application-specific glue code.

The important design point is that MCP makes tools easier to expose, so tool authorization becomes more important.

Production extension:

- Connect the official Terraform MCP Server in read-only mode first.
- Add a custom Kubernetes MCP server.
- Authorize every tool call based on actor, resource, and action.

## Decision 3: Use Permission-Aware RAG

Infrastructure answers should be grounded in docs, runbooks, postmortems, and change procedures. RAG is the right pattern for that, but retrieved context must be treated as protected data.

The demo filters documents before they become model-visible context.

Production extension:

- Use vector or hybrid search.
- Store permissions at the chunk level.
- Back authorization with SpiceDB/AuthZed.

## Decision 4: Separate Answering From Acting

The assistant can inspect, explain, and propose. It does not directly mutate production.

This matches platform engineering norms: plan, review, approve, execute, and audit.

Production extension:

- Route approved actions into CI/CD, incident, or change-management workflows.
- Keep destructive actions behind explicit approvals.

## Decision 5: Make Auditability Visible

The demo shows retrieval decisions, tool authorization decisions, proposal state, approval events, and final answer context.

This is important because AI workflow trust depends on understanding how the answer was produced.

Production extension:

- Persist audit events.
- Add OpenTelemetry traces.
- Add evals for unauthorized retrieval, prompt injection, and unsafe tool use.

