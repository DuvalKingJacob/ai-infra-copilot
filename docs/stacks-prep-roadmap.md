# Stacks Prep Roadmap

This repo should model the HashiBank Stacks architecture, not copy it wholesale.

The goal is to prepare the next practitioner deep dive:

> From workspace sprawl to Terraform Stacks, with AI-assisted blast-radius review.

## Positioning

The first video proves the plan review pattern:

```text
Terraform plan -> AI review -> policy signal -> authorization boundary -> human approval
```

The Stacks follow-up should prove the dependency-context pattern:

```text
workspace sprawl -> Stack components -> deployment groups -> AI blast-radius explanation -> approval boundary
```

Use `docs/stacks-video-validation-checklist.md` to validate product accuracy, series fit, demo readiness, and recording safety before publishing.

## Source Of Inspiration

Use the companion repo as the real practitioner reference:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

But keep this repo small and sanitized:

- no real account IDs
- no real ARNs
- no org-specific workspace names
- no local Terraform state
- no provider-heavy dependency for the default demo path

## What To Model Here

The local scenario should mirror the shape of HashiBank:

```text
network -> cluster -> platform services -> application
```

Previous local shape:

```text
vpc -> eks_cluster -> app
```

Current local shape:

```text
vpc
  -> eks_cluster
    -> platform_addons
      -> app_namespace
        -> hashibank_app
```

Keep the implementation provider-light with `terraform_data` unless the goal is a live HCP Terraform demo.

## Why This Helps The AI Story

Single-workspace plan review answers:

> Is this plan risky?

Stacks-aware review answers:

> What components are affected, what depends on them, what environments are in scope, and where should approval happen?

That is a better platform engineering story because it moves from resource-level risk to system-level risk.

## Demo Questions The Agent Should Answer

Use questions like:

- Which Stack components are affected by this app change?
- Does the app change depend on cluster or network outputs?
- Is this change isolated to dev, or does it affect prod?
- Which policies apply at the component or deployment boundary?
- Who is allowed to inspect this Stack context?
- Should this proceed automatically, require approval, or be blocked pending review?

## Local Artifacts Added

These are now present in the local scenario:

1. `terraform/workspace-to-stacks/modules/platform-addons`
2. `terraform/workspace-to-stacks/modules/app-namespace`
3. `terraform/workspace-to-stacks/modules/hashibank-app`
4. expanded `stack/components.tfcomponent.hcl`
5. expanded `stack/deployments.tfdeploy.hcl`
6. `terraform/workspace-to-stacks/component-graph.md`

## Local Artifacts To Add Next

Next additions:

1. a Stacks-specific review fixture under `data/`
2. a reviewer mode that summarizes component blast radius
3. a Stacks video teleprompter
4. optional HCP Terraform / `tfctl` command examples after auth is confirmed

## Production Mapping

| Local prep | HashiBank companion | HCP Terraform / TFE concept |
| --- | --- | --- |
| `modules/vpc` | AWS VPC component | network component |
| `modules/eks` | EKS Fargate component | cluster component |
| `modules/platform-addons` | EKS addons | platform services component |
| `modules/app-namespace` | Kubernetes namespace | app boundary component |
| `modules/hashibank-app` | HashiBank deployment | application component |
| local `tfcomponent.hcl` | real Stack component config | Stack component graph |
| local `tfdeploy.hcl` | dev/prod deployment groups | deployment and approval behavior |

## Video Shape

Working title:

> From Workspace Sprawl To Terraform Stacks

Hook:

> Workspaces are useful, but as platforms grow, dependencies move outside the thing Terraform can see. Stacks make the component graph explicit.

Flow:

1. Show the old workspace shape.
2. Explain the operational pain: remote state, sequencing, one-plan-at-a-time review.
3. Show the Stack component graph.
4. Explain deployments and deployment groups.
5. Ask the AI reviewer for blast radius.
6. Map the local demo to HashiBank and HCP Terraform.
7. Close with the approval boundary: AI explains, Terraform controls execution.

## Do Not Do Yet

- Do not merge the full HashiBank repo into this repo.
- Do not add real HCP Terraform org/project/workspace values.
- Do not require AWS/Kubernetes credentials for the default Stacks demo.
- Do not make the agent apply Stack changes.

## Definition Of Ready

The Stacks deep dive is ready to record when:

- the local component graph is visible in code
- the migration map explains old versus new workflow
- the demo can answer blast-radius questions without cloud credentials
- HashiBank is linked as the advanced real implementation
- the talk track clearly maps to HCP Terraform/TFE adoption
