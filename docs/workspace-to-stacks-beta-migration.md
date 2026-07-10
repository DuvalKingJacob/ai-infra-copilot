# Workspace To Stacks Beta Migration

HashiCorp's current workspace-to-Stacks migration path uses `tf-migrate`.

Source:

```text
https://developer.hashicorp.com/terraform/migrate/stacks
```

## Important Boundary

The local scenario in this repo is an educational scaffold. It models the shape of a migration:

```text
workspace roots -> modules -> Stack components -> deployments
```

It does not prove a real HCP Terraform workspace migration by itself.

A real migration requires:

- `tf-migrate` 2.0+
- Terraform 1.13+
- existing Terraform configuration deployed to one or more HCP Terraform workspaces
- Stacks enabled in the HCP Terraform organization
- cloud/provider credentials configured for Stacks if the configuration needs them

The feature is currently beta. Do not use it for production migration paths without validating current HashiCorp guidance.

## Current Local Status

Observed locally:

| Tool | Status |
| --- | --- |
| Terraform | installed |
| `tf-migrate` | not installed |

The provider-light workspace roots validate locally:

```bash
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/eks-cluster init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/eks-cluster validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app validate
```

## Real Migration Flow

The documented beta flow is:

1. Modularize any root module resources into child modules.
2. Run `tf-migrate stacks prepare`.
3. Configure cloud credentials for Stacks if needed.
4. Run `tf-migrate stacks execute`.
5. Review the generated Stack in HCP Terraform.
6. Remove or set `import = false` when ready to make changes with the migrated Stack.

## Commands To Test Once `tf-migrate` Is Installed

Check tool availability:

```bash
tf-migrate version
terraform version
```

From a real HCP Terraform-backed workspace configuration:

```bash
tf-migrate modules create
cd modularized_config
terraform init
tf-migrate stacks prepare
tf-migrate stacks execute
```

The `prepare` command should generate:

```text
_stacks_generated/
stacks_migration_infra/
```

## Demo Positioning

For the video series:

- Use this repo to teach the mental model safely.
- Use `tf-migrate` only when demonstrating a real beta migration against HCP Terraform.
- Be explicit that beta behavior may change.
- Avoid recording account IDs, organization names, state contents, or generated live migration files that should stay private.
