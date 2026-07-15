# HashiBank Stacks Companion Scenario

This AI infrastructure operations repo has a simplified local workspace-to-Stacks scenario under:

```text
terraform/workspace-to-stacks
```

There is also a real companion Stacks repo:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

Local clone inspected:

```text
/Users/jacobplicque/Projects/tfstacks-vpc-eks-hashibank
```

## Why Keep Both?

The local scenario in this repo is intentionally provider-free. It uses `terraform_data` so the AI demo can run anywhere and focus on the workflow:

```text
workspace sprawl -> Stack components -> plan review -> policy signal -> approval
```

The HashiBank repo is the richer practitioner implementation:

```text
VPC -> EKS Fargate -> Kubernetes RBAC -> EKS addons -> namespace -> HashiBank app
```

That makes it better for a deeper Terraform/HCP Terraform walkthrough, but less ideal as the first local AI demo because it depends on AWS, HCP Terraform, OIDC, Kubernetes, Helm, and real account configuration.

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

Use this repo first:

- local demo
- plan review
- authorization boundary
- policy signal
- AI report

Use the HashiBank companion second:

- real Stacks architecture
- VPC/EKS/app dependency graph
- HCP Terraform deployment groups
- OIDC for non-human identity
- deeper practitioner walkthrough

## Caution

Do not blindly copy the companion repo into this project. It contains real-environment configuration such as account IDs, ARNs, organization names, and local Terraform artifacts. Keep the AI demo repo small and sanitized, and link to the companion as the advanced implementation.
