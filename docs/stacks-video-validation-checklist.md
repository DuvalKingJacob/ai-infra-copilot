# Stacks Video Validation Checklist

Use this checklist before recording or sharing the Stacks deep-dive package.

The goal is to validate that the video is technically accurate, clearly differentiated from the overview episode, and grounded in a demo that can survive recording.

## Positioning

Working title:

> From Workspace Sprawl To Terraform Stacks

Core thesis:

> Stacks make Terraform dependency context explicit. That context helps platform teams coordinate infrastructure lifecycle, review blast radius, and govern changes through HCP Terraform / Terraform Enterprise.

This should be the practitioner deep dive that follows the higher-level Stacks overview. It should not repeat the whole overview script.

## Source Material

| Source | Purpose | Status |
| --- | --- | --- |
| Steve's `Episode 1_ Beyond the Workspace` script | Positioning baseline for the high-level Stacks overview | reviewed |
| Steve's `Terraform Enterprise Video Series - Overview` | Series-level fit and episode sequencing | reviewed |
| HashiCorp Stacks docs | Product truth for components, deployments, deployment groups, and HCP Terraform workflow | needs final reread before recording |
| Terraform MCP Server docs | Product truth for MCP capabilities, HCP Terraform/TFE access, and security caveats | needs final reread before recording |
| Existing HashiConf / HashiCorp YouTube Stacks walkthrough | Continuity check against previous public explanation | deck inspected |
| `HashiCorp_PresentationKit_JacobPlicqueFinal.key` | Local copy of the HashiConf talk deck and embedded demo source | inspected |
| `tfstacks-vpc-eks-hashibank` companion repo | Advanced real implementation reference | needs human review |
| This repo's local Stacks scenario | Safe demo and teaching scaffold | ready for local validation |

## HashiConf Continuity Baseline

The local HashiConf deck confirms that the previous public Stacks talk already covered:

- modern applications as interdependent components: networking, databases, compute, and security
- separate workspaces creating drift, manual effort, and slower delivery
- "Taming Complexity with Terraform Stacks"
- organizing infrastructure into logical components
- deploying components as cohesive environments
- coordinated deployments with deployment group orchestration
- advanced dependency management, deferred changes, and Linked Stacks
- VCS-driven Stack architecture
- Terraform Search as an estate discovery and import story
- a live HCP Terraform / HashiBank Stacks demo

The new deep dive should build on that baseline instead of re-explaining it. The added angle is:

> Once Stacks make dependency context explicit, AI-assisted review can explain component blast radius while HCP Terraform / TFE remains the run, policy, approval, and audit control plane.

## Narrative Validation

| Claim | Validation Question | Proof |
| --- | --- | --- |
| Workspaces are useful but become difficult as orchestration boundaries | Does the script avoid saying workspaces are bad? | Steve's overview frames workspaces as strong isolation/state containers but weak orchestrators |
| Stacks coordinate modules; they do not replace modules | Does the demo show existing modules under Stack components? | `terraform/workspace-to-stacks/modules/*` and `stack/components.tfcomponent.hcl` |
| Components make dependencies visible | Does the graph show `vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app`? | `terraform/workspace-to-stacks/component-graph.md` |
| Deployments model repeatable environments | Does the script distinguish component shape from deployment targets? | `stack/deployments.tfdeploy.hcl` |
| This talk extends the HashiConf talk | Does it reuse the Stacks foundation but add AI-assisted blast-radius review? | `HashiCorp_PresentationKit_JacobPlicqueFinal.key` continuity baseline |
| HCP Terraform/TFE remains the control plane | Does the script map local files to HCP Terraform/TFE runs, policy, approvals, state, and audit? | `docs/hcp-terraform-stacks-plan.md` |
| AI is a reviewer, not an operator | Does the script stop at blast-radius explanation and approval recommendation? | `docs/stacks-prep-roadmap.md` |
| MCP provides context/tool access, not governance by itself | Does the script explain where MCP ends and policy/authorization begin? | `docs/terraform-mcp-integration.md` and `mcp/README.md` |

## Demo Validation

Run before recording:

```bash
make ci
terraform fmt -recursive terraform/workspace-to-stacks
```

Validate local workspace roots after any Terraform edits:

```bash
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/eks-cluster init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/eks-cluster validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/platform-addons init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/platform-addons validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/app-namespace init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/app-namespace validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app validate
```

Stacks-specific commands for the live path:

```bash
terraform -chdir=terraform/workspace-to-stacks/stack stacks init
terraform -chdir=terraform/workspace-to-stacks/stack stacks validate
```

Those commands may require HCP Terraform discovery and network access to `app.terraform.io`.

## Live Demo Readiness

| Requirement | Check | Status |
| --- | --- | --- |
| Terraform installed | `terraform version` | local tool present |
| `tfctl` installed | `tfctl --version` | local tool present |
| `tfctl` authenticated | `tfctl auth status` | needs user check |
| AWS identity available | `aws sts get-caller-identity` | needs user check |
| Kubernetes context correct | `kubectl config current-context` | needs user check |
| Helm available if charts are used | `helm version --short` | local tool present |
| HCP Terraform org/project/workspace values sanitized | manual review | required before recording |
| No secrets in repo | `git status --short` and secret scan | required before push |

## Series Fit

This deep dive should complement the planned Terraform Enterprise series:

| Series Episode | Relationship |
| --- | --- |
| Episode 1: Stacks overview | This video becomes the hands-on practitioner companion |
| Episode 2: Policy | Mention as the next governance layer, but do not deep dive Sentinel/OPA here |
| Episode 3: Drift | Mention dependency context as useful for drift investigation, but keep scope on Stacks |
| Episode 8: AI Estate | Reuse the AI/MCP framing, but keep this video centered on Terraform Stacks adoption |
| Episode 9: Grand Orchestration | This demo can become one component of the final end-to-end story |

## Recording Checklist

- The first two minutes answer: "Why should Terraform practitioners care?"
- The demo shows files, not only slides.
- The old workspace model is visible before the Stack model.
- The component graph is visible on screen.
- The local demo is explained as a safe reference implementation.
- The HashiBank repo is framed as the advanced real implementation, not copied into this repo.
- HCP Terraform/TFE concepts are named explicitly: runs, plans, state, policy, approvals, deployment groups, and audit logs.
- MCP and AI are positioned as context/review layers, not autonomous apply mechanisms.
- The fallback path works without cloud access.
- No account IDs, org names, tokens, ARNs, state, kubeconfigs, or live plan JSON appear in the recording.

## Definition Of Ready

The Stacks package is ready to record when:

- local validation passes
- the script has a distinct practitioner angle from Steve's overview
- claims have been checked against current HashiCorp docs
- HashiConf/YouTube continuity has been reviewed
- the HashiBank companion path has been sanity-checked
- the fallback local demo can be completed in under five minutes
- the live path has been tested, or intentionally deferred
