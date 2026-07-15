# Local Validation Runbook

This repo uses small Node.js scripts internally, but the practitioner-facing demo uses `make` targets. Treat the Node scripts as implementation details.

## What You Need Installed

- Node.js, used by the local helper scripts.
- `make`, included with the macOS command line tools.
- Docker Desktop, for running the optional SpiceDB provider locally.

Check:

```bash
node --version
make --version
docker --version
```

Use the repo path locally:

```bash
cd /path/to/ai-infra-copilot
```

## What Is Actually Running

### Browser Demo

Status: local static file.

Open:

```text
demo/index.html
```

### Optional External Authorization Provider

Status: runs locally through Docker when you start it.

Start:

```bash
docker compose up -d spicedb
```

Load schema and relationships:

```bash
make authz-load
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
- `make tool-check-local`: validates tool authorization before returning read-only Terraform-shaped output.

Validate the gateway:

```bash
make tool-check-local
```

Expected:

- Alice: allowed, returns read-only Terraform-shaped result.
- Bob: denied, result withheld.

With the optional SpiceDB provider running:

```bash
npm run tool:call -- alice terraform.get_recent_changes --provider=spicedb
npm run tool:call -- bob terraform.get_recent_changes --provider=spicedb
```

## What To Say If Asked

> I did not make Terraform MCP directly apply changes. I built the authorization gateway first, then documented the official Terraform MCP handoff. The safe production shape is: authorize the actor, allow read-only inspection, create proposals for risky actions, and keep apply behind human approval and controlled workflow handoff.

## Quick Full Check

```bash
make validate
npm run authz:validate
npm run embeddings:build
npm run rag:query -- alice "What do we know about the production outage?"
npm run tool:call -- alice terraform.get_recent_changes --provider=local
make review
make agent
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

If optional SpiceDB checks fail, rerun:

```bash
docker compose up -d spicedb
npm run authz:validate
npm run authz:load
```

If `authz:load` failed partway through and checks still look wrong, reset the in-memory optional provider container:

```bash
docker compose down
docker compose up -d spicedb
npm run authz:validate
npm run authz:load
```
