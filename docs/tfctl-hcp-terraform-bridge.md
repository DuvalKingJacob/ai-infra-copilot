# tfctl HCP Terraform Bridge

`tfctl` is a useful bridge between this local AI-assisted Terraform demo and real HCP Terraform / Terraform Enterprise workflows.

Installed locally:

```bash
tfctl --version
```

Current observed version:

```text
v0.3.0
```

## Why It Matters

This repo intentionally starts with local Terraform plan JSON so the demo is easy to inspect.

`tfctl` gives the next production-shaped step:

```text
local sample plan
  -> HCP Terraform workspace/run context
  -> run status, variables, policy checks, state metadata
  -> authorized AI review
  -> human approval
```

It should not replace Terraform MCP. They are different layers:

- `tfctl`: practitioner/operator CLI for HCP Terraform and Terraform Enterprise.
- Terraform MCP Server: model/tool protocol surface for AI assistants.
- Authorization layer: boundary before context or tool output is exposed; SpiceDB/AuthZed is one optional provider example in this repo.
- Sentinel: policy boundary for whether the infrastructure change is acceptable.

For the broader run-control model, see:

```text
docs/hcp-terraform-run-control.md
```

## Current Local Status

`tfctl` is installed, but live HCP Terraform auth was not active when checked:

```bash
tfctl auth status --json
```

Observed:

```json
{
  "hostname": "app.terraform.io",
  "active": false
}
```

Before using live HCP Terraform commands:

```bash
tfctl auth login
tfctl auth status
```

For non-interactive login:

```bash
echo "$HCP_TERRAFORM_TOKEN" | tfctl auth login --token
```

## Useful Commands For This Demo

Show agent/operator context:

```bash
tfctl harness context
```

Get current run status for a workspace:

```bash
tfctl run status WORKSPACE_NAME
```

List runs for a workspace:

```bash
tfctl api /workspaces/{workspace}/runs -p workspace=WORKSPACE_NAME --jq '.data[] | {id, status: .attributes.status}'
```

Get policy check results for a run:

```bash
tfctl api /runs/RUN_ID/policy-checks --jq '.data[] | {id: .id, status: .attributes.status, enforced: .attributes.enforcement-level}'
```

List workspace variables without exposing values:

```bash
tfctl api /workspaces/{workspace}/vars -p workspace=WORKSPACE_NAME --jq '.data[] | {key: .attributes.key, category: .attributes.category, sensitive: .attributes.sensitive}'
```

## Agent Integration

The agent can optionally request read-only HCP Terraform/TFE context through `tfctl` after authorization.

Without a workspace configured, the command degrades safely and explains what is missing:

```bash
make agent-tfctl
make tool-check-tfctl
```

With a workspace:

```bash
TFCTL_WORKSPACE=WORKSPACE_NAME make agent-tfctl
TFCTL_WORKSPACE=WORKSPACE_NAME make tool-check-tfctl
```

Equivalent direct command:

```bash
node src/agent-workflow.mjs alice "Should we apply the Terraform change?" \
  --provider=local \
  --terraform-context=tfctl \
  --workspace=WORKSPACE_NAME
```

This path currently reads:

- current run status through `tfctl run status`
- workspace variable metadata through `tfctl api /workspaces/{workspace}/vars`

It does not start runs, approve runs, apply Terraform, delete resources, or expose sensitive variable values.

## Demo Safety Rules

Use `tfctl` as a read-only inspection layer first.

- Prefer `tfctl run status`, `tfctl get`, and `tfctl api` reads.
- Use `--jq` instead of piping to external `jq`.
- Use `--dry-run` for anything that might mutate.
- Do not use DELETE from an AI-driven workflow.
- Do not expose sensitive variable values to a model.
- Do not let an agent start or approve production runs without a human workflow.

## How It Fits The Video Story

In the first video, `tfctl` is optional.

The local demo proves the control pattern:

```text
Terraform plan -> AI review -> policy signal -> authorization boundary -> human approval
```

In a follow-up video, `tfctl` can show the HCP Terraform version of the same idea:

```text
HCP Terraform run -> policy checks -> run status -> AI summary -> approval decision
```

That is the natural bridge to:

- HCP Terraform run history
- Sentinel policy checks
- workspace variables
- Stack deployments
- Terraform MCP context
- agent safety boundaries
