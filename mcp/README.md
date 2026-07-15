# MCP Integration

The demo currently uses a read-only gateway for MCP-style tools. The goal is to put authorization in front of tool execution before connecting to the official Terraform MCP Server.

## Current Gateway

Run:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=local
npm run tool:call -- bob terraform.get_recent_changes --provider=local
```

With the optional SpiceDB provider running and loaded:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=spicedb
```

The gateway performs the core security check:

```text
Can actor X call tool Y?
```

If allowed, it returns read-only infrastructure output. If denied, it withholds the tool result.

## Official Terraform MCP Server

See:

`terraform-mcp.example.json`

This config shows how the official HashiCorp Terraform MCP Server would be registered with an MCP client.

## Intended Production Shape

1. Agent requests Terraform context.
2. Gateway authorizes the actor and requested tool.
3. Allowed read-only calls are routed to Terraform MCP.
4. Planning remains proposal-only.
5. Apply remains outside the agent and behind approval.

## Why Not Direct Apply

The project intentionally avoids agent-triggered production mutation. Terraform changes should go through controlled workflows such as CI/CD, Terraform Cloud run approval, or incident remediation approval.
