# Production Milestones

This file turns the remaining gaps into concrete, honest milestones.

The milestones follow one product principle:

> AI should augment Terraform workflows without creating a parallel infrastructure control plane.

HCP Terraform or Terraform Enterprise remains the system of record for runs, plans, policy checks, approvals, variables, state, and audit. Interfaces such as `tfctl` and the Terraform MCP Server should be treated as controlled access paths into that system, not replacements for it.

Future issue candidates that are not yet milestones live in `docs/ai-repo-backlog.md`.

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

## Milestone 2: Optional External Authorization Provider

Status: executable CLI path added.

Files:

- `spicedb/schema.zed`
- `spicedb/relationships.yaml`
- `spicedb/README.md`
- `docker-compose.yml`
- `src/load-spicedb.mjs`
- `src/authz-check.mjs`
- `src/spicedb-client.mjs`

Why this matters:

- Shows how local role checks could be replaced by an external relationship-based authorization provider.
- Keeps authorization around AI context and tool access visible without making any one authorization vendor required for the Terraform workflow.

Run:

```bash
docker compose up -d spicedb
npm run authz:load
npm run authz:check -- alice document:postmortem-platform-204 read --provider=spicedb
npm run rag:query -- alice "What do we know about the production outage?" --provider=spicedb
```

Next step:

- Wire the browser demo to a backend that calls SpiceDB instead of using an in-browser permission map.
- Extend the schema from direct user relationships to team, tenant, customer, and environment relationships.

## Milestone 3: Official Terraform MCP Server

Status: read-only authorization gateway added, official server config added.

Files:

- `mcp/terraform-mcp.example.json`
- `docs/terraform-mcp-integration.md`
- `src/tool-call.mjs`

Why this matters:

- Moves from MCP-shaped mock tools to a real infrastructure MCP server.
- Creates a natural demo of tool authorization and sensitive Terraform data boundaries.

Next step:

- Replace the gateway's mock read-only Terraform result with an actual call to the official Terraform MCP Server.
- Leave workspace mutation disabled.
- Document which Terraform data is safe to expose to the MCP client and which data should require additional authorization or redaction.

## Milestone 3.5: HCP Terraform / TFE Control Plane Interface

Status: bridge notes added.

Files:

- `docs/tfctl-hcp-terraform-bridge.md`
- `docs/video-demo-runbook.md`

Why this matters:

- `tfctl` gives humans, scripts, and coding agents a CLI-shaped way to interact with HCP Terraform/TFE workflows.
- The demo should show that AI-assisted review improves the existing Terraform run model rather than replacing it.
- Runs, plans, policy checks, approvals, variables, state, and audit logs remain the production control points.

Next step:

- Add an authenticated, read-only `tfctl` walkthrough once a safe HCP Terraform/TFE environment is available.
- Keep `terraform apply` out of the local agent path.

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

## Future Scenario: AI-Assisted Drift Triage

Status: roadmap item.

Why this matters:

- Large Terraform estates can produce more drift events than a platform team can manually triage.
- The same architecture used for plan review can extend to drift review: collect authorized context, classify risk, recommend next steps, and stop before mutation.
- Drift triage is a strong practitioner scenario because it starts with a real operational problem rather than a generic chatbot prompt.

Production-shaped workflow:

1. HCP Terraform or Terraform Enterprise detects drift.
2. An authorized agent gathers read-only workspace, project, ownership, policy, run, and dependency context.
3. The agent groups drift by severity and recommended handling path.
4. Humans review the recommendation.
5. Terraform remains the system of record for remediation runs, approvals, state, and audit.

Non-goal:

- Do not build an autonomous drift fixer that applies changes outside the Terraform run lifecycle.
