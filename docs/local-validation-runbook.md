# Local Validation Runbook

This repo uses small Node.js scripts, but you do not need to be a Node.js developer to run the demo. Treat the commands as project utilities.

## What You Need Installed

- Node.js, which includes `npm`.
- Docker Desktop, for running SpiceDB locally.

Check:

```bash
node --version
npm --version
docker --version
```

Use either path locally:

```bash
cd /Users/jacobplicque/Documents/Codex/2026-06-21/context-i-am-a-senior-tpmm/work/authzed-ai-infra-copilot
```

The old path also works as a compatibility symlink:

```bash
cd /Users/jacobplicque/Documents/Codex/2026-06-21/context-i-am-a-senior-tpmm/work/ai-infra-copilot
```

## What Is Actually Running

### Browser Demo

Status: local static file.

Open:

```text
demo/index.html
```

### SpiceDB

Status: runs locally through Docker when you start it.

Start:

```bash
docker compose up -d spicedb
```

Load schema and relationships:

```bash
npm run authz:validate
npm run authz:load
```

Validate:

```bash
npm run authz:check -- alice document:postmortem-platform-204 read --provider=spicedb
npm run authz:check -- bob document:postmortem-platform-204 read --provider=spicedb
```

Expected:

- Alice: `allow`
- Bob: `deny`

### Terraform MCP

Status: not running as a live server yet.

What exists today:

- `mcp/terraform-mcp.example.json`: official Terraform MCP Server config.
- `src/tool-call.mjs`: authorization gateway for MCP-style tool calls.
- `npm run tool:call`: validates tool authorization before returning read-only Terraform-shaped output.

Validate the gateway:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=local
npm run tool:call -- bob terraform.get_recent_changes --provider=local
```

Expected:

- Alice: allowed, returns read-only Terraform-shaped result.
- Bob: denied, result withheld.

With SpiceDB running:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=spicedb
npm run tool:call -- bob terraform.get_recent_changes --provider=spicedb
```

## What To Say If Asked

> I did not make Terraform MCP directly apply changes. I built the authorization gateway first, then documented the official Terraform MCP handoff. The safe production shape is: authorize the actor, allow read-only inspection, create proposals for risky actions, and keep apply behind human approval and controlled workflow handoff.

## Quick Full Check

```bash
npm run check
npm run authz:validate
npm run embeddings:build
npm run rag:query -- alice "What do we know about the production outage?"
npm run tool:call -- alice terraform.get_recent_changes --provider=local
npm run terraform:review
```

## Troubleshooting

If `npm` is missing:

```bash
brew install node
```

If Docker commands fail, open Docker Desktop and wait for it to finish starting.

The common error is:

```text
Cannot connect to the Docker daemon
```

That means Docker Desktop is not running yet.

If SpiceDB checks fail, rerun:

```bash
docker compose up -d spicedb
npm run authz:validate
npm run authz:load
```

If `authz:load` failed partway through and checks still look wrong, reset the in-memory SpiceDB container:

```bash
docker compose down
docker compose up -d spicedb
npm run authz:validate
npm run authz:load
```
