# Stacks Live Prerequisites

This repo keeps the default Stacks demo provider-light, but the advanced HashiBank-style path needs real tooling and access.

## Current Local Tooling

Observed locally:

| Tool | Status |
| --- | --- |
| Terraform | installed: `1.15.5` |
| `tfctl` | installed: `0.3.0` |
| AWS CLI | installed: `2.27.28` |
| `kubectl` | installed: `1.35.3` |
| Helm | installed: `4.1.3` |
| Docker | installed: `28.4.0` |
| HCP CLI | not found |

Terraform reported that a newer patch version is available. Updating is optional for the local demo, but staying current is useful before recording live HCP Terraform or Stacks content.

## Needed For The Local Stacks Demo

The sanitized local scenario only needs:

- Terraform
- this repository

It uses `terraform_data` resources so it can be formatted, inspected, and validated without AWS, Kubernetes, Helm, or HCP Terraform access.

## Needed For The HashiBank Companion Demo

The richer companion path needs:

- Terraform with Stacks support.
- HCP Terraform / Terraform Enterprise access.
- `tfctl` authenticated to the right HCP Terraform host.
- AWS CLI authenticated to the target account.
- OIDC or another non-static credential path for AWS in HCP Terraform.
- `kubectl` for cluster inspection.
- Helm if the app/add-on path uses charts.
- Access to the companion repo:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

## Commands To Check Before Recording

```bash
terraform version
tfctl --version
tfctl auth status
aws sts get-caller-identity
kubectl config current-context
helm version --short
docker --version
```

For Stacks specifically:

```bash
terraform -chdir=terraform/workspace-to-stacks/stack stacks init
terraform -chdir=terraform/workspace-to-stacks/stack stacks validate
```

Those Stacks commands may require HCP Terraform discovery and network access to `app.terraform.io`.

## What Not To Commit

Do not commit:

- local `.terraform/` directories
- Terraform state
- live plan JSON
- cloud account IDs
- ARNs
- kubeconfigs
- HCP organization or project values that should stay private
- generated live outputs under `outputs/live-*`

## Recommended Next Step

Use this repo for the educational local story first. Use the HashiBank companion repo when the video needs a real HCP Terraform / AWS / Kubernetes implementation.
