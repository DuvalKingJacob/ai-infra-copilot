# HCP Terraform And Stacks Plan

This repo should not jump straight into live HCP Terraform automation.

The next useful milestone is a controlled migration story:

```text
workspaces -> modules -> stack components -> deployments -> policy/approval -> MCP context
```

## Why Not Full HCP Terraform Yet?

Full HCP Terraform integration requires real organization/project/workspace setup, credentials, variable sets, policy sets, and run history. That is valuable, but it is not the first thing the demo needs.

The demo needs to prove the educational workflow first:

- what the old workspace shape looks like
- why coordination becomes painful
- how Stacks model the same system as components and deployments
- where policy and approval gates fit
- how an AI assistant can explain the blast radius without applying changes

## Recommended Order

1. Keep the local Terraform-native plan review as the hero demo.
2. Add the workspace-to-Stacks migration scenario.
3. Use the migration scenario in the video script.
4. Add HCP Terraform screenshots or CLI notes later.
5. Add real HCP Terraform API/MCP integration only after the local story is tight.

## HCP Terraform Integration Later

Future additions could include:

- HCP Terraform project and workspace naming conventions.
- Variable set examples for cloud credentials and environment defaults.
- Policy set mapping for the Sentinel examples.
- Run task positioning for cost/security checks.
- `tfctl` commands for run status, policy checks, variables, and workspace context.
- Terraform MCP Server configuration for workspace, registry, and run context.
- Stack deployment group examples for dev and prod promotion.

## Companion Implementation

The richer Stacks companion repo is:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

It should be used as the advanced practitioner scenario once the local AI review story is clear. See:

```text
docs/hashibank-stacks-companion.md
```

For the CLI bridge from local demo to HCP Terraform, see:

```text
docs/tfctl-hcp-terraform-bridge.md
```

## Talk Track

> The first version runs locally so the workflow is easy to inspect. In production, HCP Terraform becomes the control plane: workspaces and Stacks hold state and run history, Sentinel enforces policy, deployment groups manage approval behavior, and MCP provides authorized context to agents.
