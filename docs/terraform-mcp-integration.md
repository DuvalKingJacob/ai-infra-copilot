# Terraform MCP Integration

This project currently uses MCP-style mock tools in the browser demo. The next integration step is to connect the official HashiCorp Terraform MCP Server in read-only mode.

## Why This Matters

Terraform is a natural fit for this portfolio project because it connects AI agents to infrastructure state, change history, modules, workspaces, and eventually plans.

It is also a strong authorization story:

> MCP makes Terraform accessible to an agent. Authorization decides which Terraform capabilities the agent may use.

## Official Server Shape

The official Terraform MCP Server supports:

- Stdio transport.
- Streamable HTTP transport.
- Terraform Registry integration.
- HCP Terraform / Terraform Enterprise support.
- Workspace operations.
- OpenTelemetry metrics in HTTP mode.

HashiCorp's README includes an explicit security note: depending on the query, the MCP server may expose Terraform data to the MCP client and LLM. That is exactly why this project places authorization and approval gates around tool access.

## Safe Integration Strategy

Start with read-only behavior:

1. Enable Terraform Registry queries.
2. Add HCP Terraform read-only workspace inspection.
3. Put the MCP server behind a tool authorization gateway.
4. Keep mutation tools disabled.
5. Log every tool call and policy decision.

Only later, and only with approval gates, introduce planning or mutation workflows.

## Example Config

See:

`mcp/terraform-mcp.example.json`

## Production Policy Questions

- Can this user list all workspaces or only workspaces for their team?
- Can this agent read variables?
- Are sensitive outputs ever exposed to the model?
- Are workspace operations disabled by default?
- Does production require approval even for users who can create plans?
- Are MCP tool calls traced and auditable?

## Non-Goal

The demo should not directly apply Terraform changes from an LLM response. Approved actions should hand off to a controlled workflow such as CI/CD, a change-management system, or Terraform Cloud run approval.

