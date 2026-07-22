# Building Your First Terraform Stack

This is the first practitioner walkthrough episode for the Terraform Enterprise video series.

Steve's lightboard explains why Stacks exist. This walkthrough shows how a practitioner authors, reviews, and operates a real Stack.

## Recommendation

Use the HashiBank Stacks repo as the primary recording demo:

```text
https://github.com/DuvalKingJacob/tfstacks-vpc-eks-hashibank
```

Use this repo's local `terraform/workspace-to-stacks` scenario as the safe fallback and teaching scaffold.

Do not make `tf-migrate` or workspace-to-Stacks migration the first video. Migration is a future, dedicated episode.

## HashiConf Talk Alignment

The original HashiConf HashiBank talk is the narrative source of truth for this walkthrough. Preserve its strongest teaching sequence:

```text
complexity -> Stack model -> coordinated deployment -> deferred work -> approval posture -> published output
```

The talk introduced three practitioner capabilities that should remain visible:

- coordinated deployments through deployment groups
- dependency management through deferred changes and linked outputs
- a VCS-driven workflow in which configuration and deployment behavior are reviewed as code

Use the talk's practical adoption test:

> Consider Stacks when teams spend more time wiring configurations together than configuring the infrastructure itself.

Do not copy the old talk mechanically. Use the current GA file shapes and current product behavior. Keep workspace migration in the later `tf-migrate` episode.

## Target Outcome

By the end, the viewer should understand:

- why workspace sprawl becomes hard to operate
- how Stacks model a real platform as components and deployments
- how component outputs become downstream inputs
- how deployment groups shape dev/prod approval posture
- how HCP Terraform / Terraform Enterprise remains the control plane
- what Stacks do and do not orchestrate
- why migration tooling belongs after the Stack model is clear

## Primary Demo

Local clone:

```text
/Users/jacobplicque/Projects/tfstacks-vpc-eks-hashibank
```

Primary files:

```text
components.tfcomponent.hcl
deployments.tfdeploy.hcl
providers.tfcomponent.hcl
variables.tfcomponent.hcl
outputs.tfcomponent.hcl
aws-vpc/
aws-eks-fargate/
k8s-rbac/
aws-eks-addon/
k8s-namespace/
hashibank-deploy/
```

Architecture:

```text
VPC
  -> EKS Fargate
    -> Kubernetes RBAC
      -> EKS add-ons
        -> namespace
          -> HashiBank app
```

## Local Fallback

If the live HashiBank path is not ready, use this repo's provider-light scaffold:

```text
terraform/workspace-to-stacks
```

It mirrors the same shape without AWS, Kubernetes, Helm, or HCP Terraform credentials:

```text
vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app
```

This fallback is for recording safety, not the preferred first story.

## Demo Spine

The spine is not "run a migration." The spine is:

```text
components -> dependencies -> deferred work -> deployment groups -> published output
```

Show that a Stack makes the platform operating model visible and lets HCP Terraform coordinate the deployment lifecycle.

### Before Mental Model

Separate workspace-shaped layers:

```text
network workspace
cluster workspace
platform services workspace
namespace workspace
application workspace
```

Operational pain:

- dependency context lives in remote state, variables, CI order, or runbooks
- review is fragmented across multiple runs
- promotion and approval behavior are hard to explain as one system
- humans carry too much of the orchestration model in their heads

### Stack Mental Model

Show:

```text
components.tfcomponent.hcl
deployments.tfdeploy.hcl
```

Practitioner takeaway:

> Stacks do not replace modules. Modules remain the implementation units. Stacks coordinate modules as components across deployments.

## Preflight

For this repo:

```bash
make validate
terraform fmt -recursive terraform/workspace-to-stacks
```

For the HashiBank repo, run only safe read/format checks before recording unless cloud access is intentionally part of the demo:

```bash
cd /Users/jacobplicque/Projects/tfstacks-vpc-eks-hashibank
git status --short
terraform fmt -check -recursive
terraform version
```

Do not show unsanitized account IDs, ARNs, organization names, state, kubeconfigs, or live plan output on screen.

### Live Run Safety Gate

Do not trigger the current HashiBank configuration from VCS until all of these are true:

- `destroy = true` is absent from the recording deployment
- account IDs, role ARNs, usernames, and organization names are replaced with recording-safe values or HCP-managed variables
- comments match the active configuration and do not describe blocks as commented out when they are enabled
- the target deployments and AWS resources are disposable and confirmed
- the development deployment has been tested immediately before recording
- the exact commit and expected component sequence are documented

For this recording, production is not part of the live execution path. Its historical state references an AWS account that the current deployment identity cannot access. Show the production deployment and manual approval posture in configuration only until the stale state is cleared by the Stacks team.

If any item is unresolved, use a previously captured run or stay in code-inspection mode.

## Recording Plan

### 1. Start With The Operational Test

Open with the HashiConf talk's practical threshold:

> If you spend more time wiring configurations together than configuring the infrastructure itself, you have reached the point where Stacks are worth evaluating.

Show the workspace-shaped layers briefly, then move directly to the Stack configuration.

### 2. Show The Platform Shape

Show the repo root and the component folders:

```bash
find . -maxdepth 2 \( -name '*.tf' -o -name '*.hcl' \) -type f | sort
```

Say:

> This is not a toy single-resource Stack. It is a platform-shaped Stack: network, cluster, Kubernetes permissions, add-ons, namespace, and application.

### 3. Show Components

Open:

```text
components.tfcomponent.hcl
```

Call out:

- `component "vpc"`
- `component "eks"`
- `component "k8s-rbac"`
- `component "k8s-addons"`
- `component "k8s-namespace"`
- `component "deploy-hashibank"`
- `for_each = var.regions`
- downstream inputs such as `component.vpc[each.value].vpc_id`
- explicit `depends_on` where operational sequencing matters

Say:

> The interesting part is not that each component exists. The interesting part is that the dependency graph is now visible in the configuration reviewers can inspect.

### 4. Show The Dependency Handoff

Use the VPC to EKS handoff:

```text
component.vpc[each.value].vpc_id
component.vpc[each.value].private_subnets
```

Say:

> In a workspace-only model, this relationship often hides behind remote state, copied variables, CI sequencing, or documentation. In a Stack, the relationship becomes part of the reviewed configuration.

Connect this explicitly to deferred work:

> Kubernetes resources cannot be planned completely until the EKS endpoint and credentials exist. The Stack records that dependency, defers the affected work, and continues it when those values become available.

Do not imply that every component waits. Point to the components that consume EKS outputs and explain why their work is deferred.

### 5. Show The Coordinated Run

Preferred path, when the live-run safety gate is satisfied:

1. Show the clean recording commit.
2. Start a new development deployment or open the previously successful development deployment.
3. Follow the HCP Terraform development deployment timeline.
4. Point out which component plans can proceed immediately.
5. Point out which Kubernetes-facing component work is deferred.
6. Show the follow-up plan or convergence check after the EKS values resolve.

Do not use **Retry deployment run** after changing code or variable-set values. Retry replays the failed deployment's existing configuration version. Use **Start new run** so HCP Terraform evaluates the current VCS revision and current inputs.

Say:

> This is the important behavior from the original HashiBank demo. HCP Terraform is coordinating the component lifecycle from the dependency graph. The deferred work is visible; it is not hidden in a custom pipeline.

If a clean live run is not available, use a previously captured run and keep the code inspection live.

### 6. Show Deployments And Approval Posture

Open:

```text
deployments.tfdeploy.hcl
```

Call out:

- identity tokens for AWS and Kubernetes
- `deployment_auto_approve "safe_dev_plans"`
- `deployment_group "dev_group"`
- `deployment_group "prod_group"`
- `deployment "development"`
- `deployment "prod"`

Say:

> The component model answers what the platform is. The deployment model answers where and how it runs. Dev can have safer auto-approval rules. Prod can keep manual approval posture.

Use the successful development deployment to show the actual auto-approval outcome:

- development passes the configured auto-approval check when the plan removes no resources

Show the production deployment group's manual approval posture in configuration, but do not open or execute the unhealthy production deployment during recording.

Say:

> Auto-approval is an explicit rule in the Stack configuration. Production's manual gate is equally explicit. The platform team is defining different operating postures for the same component model.

### 7. Show The Published Output

Open:

```text
components.tfcomponent.hcl
deployments.tfdeploy.hcl
```

Call out:

```text
output "published_vpc_id"
publish_output "vpc_id"
```

Say:

> The original talk ended by publishing the VPC ID for another Stack to consume. This repository demonstrates the publishing side of that contract. A separate consuming Stack is required for a complete Linked Stacks demo.

Keep the consumer as an optional extension unless the recording environment includes and validates that second Stack.

### 8. Map To HCP Terraform / TFE

Say:

> In production, HCP Terraform or Terraform Enterprise owns the run lifecycle: plan, policy, deployment behavior, approval, state, outputs, and audit. Stacks give that control plane a more explicit model of the platform.

Mention:

- runs
- plans
- state
- deployment groups
- policy checks
- approvals
- audit logs
- published outputs

### 9. Explain What Stacks Do Not Do

Say:

> Stacks improve orchestration and dependency visibility, but they are not magic rollback. Components still have state boundaries. Failure recovery still requires inspecting the failed component, fixing the issue, and rerunning through the governed workflow.

Avoid implying:

- Stacks replace modules
- Stacks auto-fix failed deployments
- Stacks make Drift Detection Stack-native
- an AI agent should apply changes directly

### 10. Bridge To The Local Scaffold

If the live path is not safe to show, switch to:

```text
terraform/workspace-to-stacks
```

Show:

```bash
sed -n '1,120p' terraform/workspace-to-stacks/component-graph.md
sed -n '1,160p' terraform/workspace-to-stacks/stack/components.tfcomponent.hcl
sed -n '1,120p' terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl
```

Say:

> This local scaffold exists so the same mental model can be reviewed without cloud credentials. It is not the main demo, but it is the fallback path that keeps the recording safe.

### 11. Close With The Migration Boundary

Say:

> If you already have existing HCP Terraform workspaces, migration is its own topic. For this walkthrough, I am starting with the Stack model directly so the architecture is clear before we talk about converting existing estates.

## Commands

Primary HashiBank inspection:

```bash
cd /Users/jacobplicque/Projects/tfstacks-vpc-eks-hashibank
git status --short
terraform fmt -check -recursive
find . -maxdepth 2 \( -name '*.tf' -o -name '*.hcl' \) -type f | sort
sed -n '1,220p' components.tfcomponent.hcl
sed -n '1,180p' deployments.tfdeploy.hcl
sed -n '1,120p' variables.tfcomponent.hcl
sed -n '1,80p' outputs.tfcomponent.hcl
```

Before any VCS-triggered recording run, inspect the recording-safe diff and confirm no destroy directive or private identifier will appear:

```bash
git diff --check
git diff -- components.tfcomponent.hcl deployments.tfdeploy.hcl outputs.tfcomponent.hcl
```

Fallback scaffold:

```bash
cd /Users/jacobplicque/Projects/ai-infra-copilot
make validate
terraform fmt -recursive terraform/workspace-to-stacks
sed -n '1,120p' terraform/workspace-to-stacks/component-graph.md
sed -n '1,160p' terraform/workspace-to-stacks/stack/components.tfcomponent.hcl
sed -n '1,120p' terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl
```

## Recovery Path

If HashiBank has unsanitized values or live state on screen:

- stop using the live repo for the recording
- switch to the local scaffold
- explain that the production-shaped path exists, but the walkthrough is about the Stack model

If the production deployment appears unhealthy:

- do not retry, destroy, or troubleshoot it during recording
- stay on the verified development deployment
- describe production approval behavior from `deployments.tfdeploy.hcl`
- treat stale-state cleanup as a separate platform-support operation

If Stacks CLI commands fail:

- do not troubleshoot live unless the video is specifically about setup
- keep the recording focused on `components.tfcomponent.hcl` and `deployments.tfdeploy.hcl`

If `tf-migrate` comes up:

- do not run it
- say it is a future migration episode
- point to `docs/workspace-to-stacks-beta-migration.md`

## Common Mistakes

- Making the first Stacks video a beta migration demo.
- Treating Stacks as a replacement for modules.
- Treating every existing workspace as a perfect future component boundary.
- Hiding rollout order in scripts instead of modeling dependencies.
- Describing deferred work as if every component pauses at once.
- Claiming a complete Linked Stacks demo when only the publishing Stack is present.
- Assuming Stacks provide automatic rollback across every component.
- Showing account IDs, ARNs, state, kubeconfigs, or org-specific values in a public recording.
- Using **Retry deployment run** after changing the VCS revision or variable-set values and expecting it to load the new configuration.
- Depending on an unhealthy production deployment when the development deployment already proves the complete component workflow.
- Letting the AI story distract from the Terraform adoption story.

## HCP Terraform Adoption Close

> Stacks are not just a new file format. They are a way to make the operating model visible. Once the component graph is explicit, HCP Terraform and Terraform Enterprise can give teams a stronger control plane for orchestration, plans, policy, approvals, state, audit, and eventually AI-assisted review.

## Next Walkthroughs

- Adding Policy, Identity, and Cost Gates
- Detecting and Remediating Drift in HCP Terraform
- AI Should Review Terraform Plans, Not Apply Them
- Migrating HCP Terraform Workspaces To Stacks With `tf-migrate`
