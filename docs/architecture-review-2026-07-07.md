# Architecture Review: 2026-07-07

This review summarizes where the project is today and what would make it feel more real to an AuthZed, AI infrastructure, or DevRel hiring audience.

## Current State

The project has three layers:

1. Browser demo.
2. Runnable CLI experiments.
3. Production integration scaffolding.

That is a good shape for a portfolio project, but not all layers are equally real yet.

## What Is Real Today

### Browser Demo

Status: working.

The browser demo shows:

- Actor selection.
- Permission-aware document retrieval.
- MCP-style Terraform and Kubernetes tools.
- Tool authorization decisions.
- Rollback proposal flow.
- Human approval flow.
- Audit trail.

This is strongest as a demo narrative.

### Local Embedding / RAG CLI

Status: runnable.

Files:

- `src/build-embeddings.mjs`
- `src/query-rag.mjs`
- `data/docs.json`
- `data/users.json`

The CLI can build local deterministic embeddings without credentials, then run permission-aware retrieval for different actors.

This is the first part of the repo that moves beyond a static demo.

## What Is Scaffolded But Not Fully Wired

### SpiceDB/AuthZed

Status: schema and relationships exist, but the app does not call SpiceDB yet.

Files:

- `spicedb/schema.zed`
- `spicedb/relationships.yaml`
- `spicedb/README.md`
- `docker-compose.yml`

This is the most important next gap because AuthZed is the target audience. The project should move at least one authorization path from local permission arrays to a real SpiceDB-backed check.

Recommended first check:

```text
Can actor X read document Y?
```

Then extend to:

```text
Can actor X call tool Y?
Can actor X approve proposal Y?
```

### Terraform MCP

Status: integration plan and example config exist, but no live tool call path yet.

Files:

- `mcp/terraform-mcp.example.json`
- `docs/terraform-mcp-integration.md`

This is useful, but it should come after SpiceDB. Terraform MCP is more operationally interesting, but AuthZed will care more that authorization is actually enforced.

### OIDC

Status: architecture plan only.

File:

- `docs/oidc-authentication-plan.md`

This can remain planned for now. Adding fake OIDC would not improve the project. Real OIDC requires a backend and identity provider configuration.

## What Should Stay Intentionally Out

### Real Production Mutation

Status: intentionally not implemented.

This is the correct decision.

The project should not directly apply Terraform or mutate Kubernetes from an agent response. The stronger architecture is:

1. Inspect.
2. Explain.
3. Propose.
4. Approve.
5. Hand off to a controlled workflow.

That is a product and security decision, not a missing feature.

## Credibility Scorecard

| Area | Current credibility | Next improvement |
| --- | --- | --- |
| RAG | Medium | Use real embeddings or hybrid retrieval end-to-end |
| MCP | Medium-low | Add a small real MCP server or client adapter |
| Agents | Medium | Make planner stages explicit in code |
| Authorization | Medium | Wire SpiceDB into CLI checks |
| AuthZed relevance | Medium-high | Show SpiceDB check output in demo/docs |
| OIDC | Low | Keep as production plan for now |
| Production mutation | Correctly absent | Keep absent |
| Auditability | Medium-high | Persist audit events from CLI/demo |

## Highest-Leverage Next Step

Build a real SpiceDB-backed authorization path for the CLI.

Suggested command:

```bash
npm run authz:check -- alice document:postmortem-platform-204 read
```

Expected output:

```json
{
  "actor": "alice",
  "resource": "document:postmortem-platform-204",
  "permission": "read",
  "decision": "allow",
  "provider": "spicedb"
}
```

Then update `src/query-rag.mjs` so it can optionally use SpiceDB checks instead of local permission arrays.

## Why This Step Matters

This one change makes the project meaningfully more real for AuthZed:

- It turns the authorization story from conceptual to executable.
- It shows that RAG context filtering can be backed by relationship-based authorization.
- It gives you a concrete thing to discuss: schema design, relationships, checks, and production tradeoffs.

## Recommended Next Order

1. Wire SpiceDB document read checks into the CLI.
2. Wire SpiceDB tool call checks into the CLI or demo adapter.
3. Add a tiny custom MCP server for mock infra tools.
4. Connect the official Terraform MCP Server in read-only mode.
5. Add persistent audit output.
6. Leave OIDC as a documented production extension until the backend exists.

