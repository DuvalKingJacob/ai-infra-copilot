# HashiBank Stacks Companion Scenario

This AI infrastructure operations repo has a simplified local workspace-to-Stacks scaffold under:

```text
terraform/workspace-to-stacks
```

The primary practitioner walkthrough should use the real companion Stacks repo:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

Local clone inspected:

```text
/Users/jacobplicque/Projects/tfstacks-vpc-eks-hashibank
```

## Why Keep Both?

The HashiBank repo is the better first recording path because it shows a real platform-shaped Stack:

```text
VPC -> EKS Fargate -> Kubernetes RBAC -> EKS addons -> namespace -> HashiBank app
```

The local scenario in this repo is intentionally provider-free. It uses `terraform_data` so the demo can fall back to a sanitized, inspectable workflow:

```text
workspace sprawl -> Stack components -> plan review -> policy signal -> approval
```

Keep both. HashiBank carries the practitioner credibility. The local scaffold protects the recording if cloud access, screen-safety, or current product behavior gets in the way.

## What The Companion Repo Demonstrates

The companion Stack includes components for:

- AWS VPC
- AWS EKS Fargate
- Kubernetes RBAC
- EKS addons
- Kubernetes namespace
- HashiBank deployment

It also uses Stacks concepts that matter for the AI/governance story:

- `for_each` across regions
- component outputs passed into downstream components
- `depends_on` for operational sequencing
- deployment groups for dev and prod
- auto-approval rules for safer dev plans
- manual approval posture for prod
- OIDC identity tokens for AWS and Kubernetes access
- published Stack outputs

## How It Maps To This Repo

| This repo | Companion repo |
| --- | --- |
| `terraform/workspace-to-stacks/modules/vpc` | `aws-vpc` |
| `terraform/workspace-to-stacks/modules/eks` | `aws-eks-fargate` |
| `terraform/workspace-to-stacks/modules/platform-addons` | `eks-addons` |
| `terraform/workspace-to-stacks/modules/app-namespace` | Kubernetes namespace / RBAC boundary |
| `terraform/workspace-to-stacks/modules/hashibank-app` | `hashibank-deploy` |
| `stack/components.tfcomponent.hcl` | `components.tfcomponent.hcl` |
| `stack/deployments.tfdeploy.hcl` | `deployments.tfdeploy.hcl` |
| local plan review report | future HCP Terraform / Stack run context |

## AI Demo Angle

The useful AI question is not:

> Can an agent deploy HashiBank?

The useful AI question is:

> Given this Stack plan, what components are affected, what dependencies are in the blast radius, what policies apply, and who is allowed to inspect or approve the change?

That keeps the story grounded:

1. HCP Terraform / Stacks provide the infrastructure control plane.
2. Terraform MCP can expose authorized run, workspace, Stack, and registry context.
3. An authorization layer can control which actor can retrieve context or call tools.
4. Sentinel/policy checks decide whether the infrastructure change is acceptable.
5. Human approval controls production-impacting execution.

## Recommended Content Use

Use the HashiBank companion first:

- real platform-shaped Stacks architecture
- VPC/EKS/app dependency graph
- HCP Terraform deployment groups
- OIDC for non-human identity
- production-shaped practitioner walkthrough

Use this repo second:

- fallback local demo
- sanitized file-shape explanation
- plan review and AI report tie-in
- authorization and policy boundary explanation

## Recording Safety

The recording copy now references environment-specific account, role, administrator, and organization values through the HCP Terraform variable set `hashibank-stack-runtime`. It does not contain a deployment marked for destruction, and its checked configuration no longer contains the original account identifiers.

Before recording or pushing, repeat the static scan and inspect the HCP Terraform UI separately. Do not show variable-set contents, state, account IDs, role values, kubeconfigs, or cloud-provider output on screen.

## Verified Recording State

The development deployment has completed successfully through the full component chain: VPC, EKS 1.34, Kubernetes RBAC, EKS add-ons, namespace, and a running HashiBank workload. Use that deployment as the live recording path.

The production deployment contains stale historical state for an IAM OIDC provider in a different AWS account. The current deployment role cannot refresh that object, so planning and destroying fail before configuration evaluation. This is an environment-recovery issue, not evidence that the current Stack configuration is invalid. Keep production out of the live recording until the Stacks team clears the stale state entry.

When code or variable-set values change, start a new deployment run. Retrying a failed deployment reuses its previous configuration version and can make fixed code appear unchanged.
