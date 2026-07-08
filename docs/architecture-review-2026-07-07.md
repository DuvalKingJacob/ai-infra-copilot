# Architecture Review: 2026-07-07

This review summarizes where the project is today and what would make it feel more useful for AI infrastructure and platform engineering audiences.

## Current State

The project has three layers:

1. Browser demo.
2. Runnable CLI experiments.
3. Production integration scaffolding.

That is a good shape for a learning project, but not all layers are equally real yet.

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

Status: executable CLI path exists; browser demo still uses local checks.

Files:

- `spicedb/schema.zed`
- `spicedb/relationships.yaml`
- `spicedb/README.md`
- `docker-compose.yml`
- `src/load-spicedb.mjs`
- `src/authz-check.mjs`
- `src/query-rag.mjs`

This is now the strongest authorization implementation path. RAG filtering can use SpiceDB checks from the CLI.

Recommended first check:

```text
Can actor X read document Y?
```

Still to extend:

```text
Can actor X call tool Y?
Can actor X approve proposal Y?
```

### Terraform MCP

Status: read-only gateway exists; official MCP handoff is configured but not fully connected.

Files:

- `mcp/terraform-mcp.example.json`
- `docs/terraform-mcp-integration.md`
- `src/tool-call.mjs`

The gateway authorizes MCP-style tools before returning read-only infrastructure data. The next step is replacing mock Terraform output with a real call to the official Terraform MCP Server.

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
| MCP | Medium | Replace mock Terraform output with official Terraform MCP read-only call |
| Agents | Medium | Make planner stages explicit in code |
| Authorization | Medium-high | Wire browser/backend path to SpiceDB |
| Relationship-based authorization | High | Extend schema to team/tenant relationships |
| OIDC | Low | Keep as production plan for now |
| Production mutation | Correctly absent | Keep absent |
| Auditability | Medium-high | Persist audit events from CLI/demo |

## Highest-Leverage Next Step

Connect the browser demo to a tiny backend that calls the same SpiceDB-backed authorization path.

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

The CLI now supports this path. The next upgrade is to make the UI use it through a backend.

## Why This Step Matters

The SpiceDB CLI path already makes the project meaningfully more real:

- It turns the authorization story from conceptual to executable.
- It shows that RAG context filtering can be backed by relationship-based authorization.
- It gives you a concrete thing to discuss: schema design, relationships, checks, and production tradeoffs.

## Recommended Next Order

1. Wire the browser demo to a backend that uses SpiceDB.
2. Extend SpiceDB relationships from direct users to teams and environments.
3. Replace mock Terraform gateway output with an official Terraform MCP read-only call.
4. Add persistent audit output.
5. Leave OIDC as a documented production extension until the backend exists.
