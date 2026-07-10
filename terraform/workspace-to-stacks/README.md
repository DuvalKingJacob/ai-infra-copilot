# Workspace To Stacks Migration Scenario

This scenario shows how a platform team might move from loosely coordinated HCP Terraform workspaces to a Stack with explicit components and deployments.

It is intentionally local and lightweight. The Terraform modules use the built-in `terraform_data` resource so the example can be formatted and inspected without cloud credentials or provider downloads.

## Old Shape: Separate Workspaces

The old workflow is represented by root modules that would often become separate workspaces:

- `workspaces/vpc`
- `workspaces/eks-cluster`
- `workspaces/platform-addons`
- `workspaces/app-namespace`
- `workspaces/hashibank-app`

Operationally, these would often become three HCP Terraform workspaces:

```text
platform-prod-vpc
platform-prod-eks
platform-prod-addons
hashibank-prod-namespace
hashibank-prod-app
```

The problem is not that workspaces are bad. The problem is that cross-workspace coordination becomes the operator's job:

- VPC outputs must be passed to the EKS workspace.
- EKS outputs must be passed to platform add-ons and app namespace workspaces.
- Namespace and service account outputs must be passed to the app workspace.
- Rollout order lives in runbooks, CI jobs, or human memory.
- Plan review happens one state file at a time.

## New Shape: Stack Components

The Stack example is represented by:

- `stack/components.tfcomponent.hcl`
- `stack/deployments.tfdeploy.hcl`

The Stack models the same lifecycle as components:

```text
vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app
```

For a visual version, see:

```text
terraform/workspace-to-stacks/component-graph.md
```

The key teaching point:

> Stacks do not replace modules. Stacks coordinate modules across deployments.

## Why This Belongs In The AI Demo

This gives the assistant a more realistic Terraform question to answer:

> If this HashiBank app change depends on namespace, platform add-ons, EKS, and VPC outputs, what else is in the blast radius?

That is exactly where Terraform context, MCP, plan review, and authorization become useful. The assistant should understand the relationship between components, but it should still stop before apply.

## Local Checks

Format traditional Terraform files:

```bash
terraform fmt -recursive terraform/workspace-to-stacks
```

Validate one legacy workspace root:

```bash
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc init
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc validate
```

Stacks validation requires HCP Terraform discovery and the Stacks CLI workflow:

```bash
terraform -chdir=terraform/workspace-to-stacks/stack stacks init
terraform -chdir=terraform/workspace-to-stacks/stack stacks validate
```

In this Codex sandbox, those commands may fail because network access to `app.terraform.io` is blocked.
