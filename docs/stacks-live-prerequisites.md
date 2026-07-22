# Stacks Live Prerequisites

The first Stacks practitioner walkthrough should use the HashiBank Stack as the primary demo. This repo keeps a provider-light scaffold as the fallback path.

## Current Local Tooling

Observed locally:

| Tool | Status |
| --- | --- |
| Terraform | installed: `1.15.5` |
| `tfctl` | installed: `0.3.0` |
| `tf-migrate` | optional for future migration episode |
| AWS CLI | installed: `2.27.28` |
| `kubectl` | installed: `1.35.3` |
| Helm | installed: `4.1.3` |
| Docker | installed: `28.4.0` |
| HCP CLI | not found |

Terraform reported that a newer patch version is available. Updating is optional for the local demo, but staying current is useful before recording live HCP Terraform or Stacks content.

## Needed For The HashiBank Primary Demo

The richer HashiBank path needs:

- Terraform with Stacks support.
- HCP Terraform / Terraform Enterprise access.
- `tfctl` authenticated to the right HCP Terraform host if CLI/API inspection is part of the recording.
- AWS CLI authenticated to the target account if live cloud inspection is part of the recording.
- OIDC or another non-static credential path for AWS in HCP Terraform.
- `kubectl` for cluster inspection.
- Helm if the app/add-on path uses charts.
- A screen-safety pass for org names, account IDs, ARNs, state, outputs, and local artifacts.
- Access to the companion repo:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

## Needed For The Local Fallback Demo

The sanitized local scenario only needs:

- Terraform
- this repository

It uses `terraform_data` resources so it can be formatted, inspected, and validated without AWS, Kubernetes, Helm, or HCP Terraform access.

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

For future migration-specific recording only:

```bash
tf-migrate version
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

Use the HashiBank companion repo for the first practitioner walkthrough if the screens are safe. Use this repo's local scaffold as the fallback. Keep `tf-migrate` for a dedicated migration walkthrough after the Stack mental model is already clear.

For the beta migration-specific path, see:

```text
docs/workspace-to-stacks-beta-migration.md
```
