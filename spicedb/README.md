# Optional SpiceDB / AuthZed Authorization Provider

The browser demo uses an in-memory permission map. The CLI path can optionally use SpiceDB/AuthZed for external relationship-based authorization checks.

## Why Include This Path

Local role checks are enough for a teaching demo, but real infrastructure teams often need an external authorization service:

- Which users can read which document chunks?
- Which teams can inspect which Terraform workspaces?
- Which agents can call which MCP tools?
- Which users can approve production-impacting actions?
- How do customer, team, tenant, and environment relationships compose?

## Model

The schema models four protected resource types:

- `document`: retrieved RAG context.
- `tool`: MCP tool call surface.
- `proposal`: action proposal and approval.
- `environment`: production/dev infrastructure boundaries.

The key design decision is that authorization wraps the objects the model depends on, not just the final answer.

## Run Locally

Start SpiceDB:

```bash
docker compose up -d spicedb
```

Load the schema and relationships:

```bash
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

If a load fails while using the in-memory datastore, reset the container before retrying:

```bash
docker compose down
docker compose up -d spicedb
npm run authz:validate
npm run authz:load
```

## Expected Checks

With SpiceDB running, the important checks would be:

```text
document:postmortem-platform-204#read@user:alice -> true
document:postmortem-platform-204#read@user:bob -> false
tool:terraform_get_recent_changes#call@user:alice -> true
tool:terraform_get_recent_changes#call@user:bob -> false
proposal:prod-rollback#approve@user:dana -> true
proposal:prod-rollback#approve@user:alice -> false
```

## Production Notes

In production, this should move from user-to-object relationships to richer team and tenant relationships:

- `team:platform#member@user:alice`
- `document:postmortem-platform-204#reader@team:platform#member`
- `environment:production#approver@team:platform-leads#member`

That is where an external relationship-based authorization system becomes much more valuable than local RBAC. SpiceDB/AuthZed is the concrete example implemented here.

## Current Limitation

The static browser demo is not yet wired to SpiceDB directly. That would require a backend service so the browser does not hold SpiceDB credentials. The CLI path exists first because it keeps credentials server-side and makes the authorization boundary explicit.

Tool names use MCP-style dotted names in the app, such as `terraform.get_recent_changes`. SpiceDB object IDs cannot contain dots, so the CLI maps them to safe IDs such as `terraform_get_recent_changes` before checking permissions.
