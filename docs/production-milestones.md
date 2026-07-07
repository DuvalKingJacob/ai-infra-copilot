# Production Milestones

This file turns the remaining gaps into concrete, honest milestones.

## Milestone 1: Real Embeddings

Status: scaffolded.

Run:

```bash
npm run embeddings:build
npm run rag:query -- alice "What do we know about the production outage?"
```

Without `OPENAI_API_KEY`, the script uses a deterministic local embedding fallback. With `OPENAI_API_KEY`, it calls the OpenAI embeddings API and writes `.cache/embeddings.json`.

Why this matters:

- Moves the project beyond keyword matching.
- Preserves the central security idea: retrieval candidates are filtered before model context.

## Milestone 2: SpiceDB/AuthZed

Status: schema and relationship model added. Not yet wired into runtime checks.

Files:

- `spicedb/schema.zed`
- `spicedb/relationships.yaml`
- `spicedb/README.md`
- `docker-compose.yml`

Why this matters:

- Replaces local role checks with relationship-based authorization.
- Directly maps the project to AuthZed's domain.

Next step:

- Add a CLI command that checks `document#read`, `tool#call`, and `proposal#approve` through SpiceDB.
- Update the RAG query path so document filtering can use SpiceDB instead of local permission arrays.

## Milestone 3: Official Terraform MCP Server

Status: integration plan and config added.

Files:

- `mcp/terraform-mcp.example.json`
- `docs/terraform-mcp-integration.md`

Why this matters:

- Moves from MCP-shaped mock tools to a real infrastructure MCP server.
- Creates a natural demo of tool authorization and sensitive Terraform data boundaries.

Next step:

- Keep the first official Terraform MCP integration read-only.
- Put it behind the same authorization gateway used for mock tools.
- Leave workspace mutation disabled.

## Milestone 4: OIDC Authentication

Status: architecture plan added.

File:

- `docs/oidc-authentication-plan.md`

Why this matters:

- Replaces the local actor selector with real identity.
- Allows authorization to depend on authenticated claims.

## Milestone 5: Production Mutation

Status: intentionally not implemented.

Why:

- Applying production infrastructure changes from a demo agent would be the wrong signal.
- The stronger product decision is to stop at proposal and approval, then hand off to CI/CD or Terraform Cloud run approval.
