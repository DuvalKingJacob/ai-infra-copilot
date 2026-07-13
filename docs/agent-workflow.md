# Agent Workflow

This repo intentionally avoids a heavyweight agent framework. The goal is to make the agentic workflow easy to inspect.

The deterministic agent runner lives at:

`src/agent-workflow.mjs`

Run:

```bash
make agent
```

With SpiceDB running:

```bash
node src/agent-workflow.mjs alice "Should we apply the Terraform change?" --provider=spicedb
node src/agent-workflow.mjs bob "Should we apply the Terraform change?" --provider=spicedb
```

With optional read-only `tfctl` context:

```bash
make agent-tfctl
TFCTL_WORKSPACE=WORKSPACE_NAME make agent-tfctl
```

The `tfctl` path is explicit and read-only. It can inspect HCP Terraform/TFE run status and workspace variable metadata after the actor is authorized to call the Terraform tool. It does not start, approve, apply, or delete runs.

## What It Demonstrates

The workflow has explicit stages:

1. Plan: classify whether the request needs docs, tools, Terraform review, Kubernetes status, or mutation.
2. Retrieve: collect candidate docs.
3. Authorize context: check document access before context becomes model-visible.
4. Call tools: request MCP-style Terraform/Kubernetes tools.
5. Authorize tools: check tool access before returning results.
6. Review risk: inspect Terraform plan findings.
7. Propose: require human approval for production-impacting actions.
8. Audit: show model-visible docs, withheld docs, returned tools, withheld tools, and mutation status.

## Why This Counts As Agent Work

The project does not claim to be a fully autonomous agent. Instead, it demonstrates the operational boundaries an agent would need:

- planning
- context retrieval
- tool calling
- delegated authority
- approval gates
- auditability
- optional read-only HCP Terraform/TFE context through `tfctl`

That is the useful part for infrastructure teams.

## What It Does Not Do

- It does not let a model decide arbitrary actions.
- It does not execute Terraform apply.
- It does not persist memory.
- It does not perform multi-agent handoffs.

Those are future extensions, not requirements for the core authorization story.
