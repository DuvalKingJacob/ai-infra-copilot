# SpiceDB / AuthZed Integration

The browser demo uses an in-memory permission map. This folder sketches how the same authorization model maps to SpiceDB/AuthZed.

## Why Add SpiceDB/AuthZed

Local role checks are enough for a teaching demo, but real infrastructure teams need relationship-based authorization:

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

## Local Test Shape

With SpiceDB running, the important checks would be:

```text
document:postmortem-platform-204#read@user:alice -> true
document:postmortem-platform-204#read@user:bob -> false
tool:terraform.get_recent_changes#call@user:alice -> true
tool:terraform.get_recent_changes#call@user:bob -> false
proposal:prod-rollback#approve@user:dana -> true
proposal:prod-rollback#approve@user:alice -> false
```

## Production Notes

In production, this should move from user-to-object relationships to richer team and tenant relationships:

- `team:platform#member@user:alice`
- `document:postmortem-platform-204#reader@team:platform#member`
- `environment:production#approver@team:platform-leads#member`

That is where SpiceDB/AuthZed becomes much more valuable than local RBAC.

