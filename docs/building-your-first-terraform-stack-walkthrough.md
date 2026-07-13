# Building Your First Terraform Stack

This is the first practitioner companion walkthrough for the Terraform Enterprise video series.

The lightboard episode explains why Stacks exist. This walkthrough shows what a practitioner should look at first.

## Format

Recording runbook, not a finished script.

Target length:

```text
8-12 minutes
```

Companion role:

```text
Steve's lightboard: why Stacks exist
Jacob's walkthrough: how practitioners should inspect and reason about a Stack
```

## Learning Objectives

Show how a platform team moves from separate workspace-shaped Terraform roots to a Stack with explicit components, deployments, and dependency context.

By the end, the viewer should understand:

- why workspace sprawl becomes hard to operate
- how Stacks coordinate modules rather than replacing them
- where components and deployments live
- how dependency context helps review blast radius
- how this maps to HCP Terraform / Terraform Enterprise
- why migration tooling should be treated as a separate workflow from the first conceptual walkthrough

## Prerequisites

Required for the local walkthrough:

- Terraform installed
- this repository

Optional for later/live demos:

- HCP Terraform or Terraform Enterprise access
- Stacks enabled in the relevant organization
- `tf-migrate` 2.0+ for the beta workspace-to-Stacks migration path
- cloud credentials if using a real AWS/Kubernetes HashiBank implementation

Do not make the first walkthrough depend on `tf-migrate`. The first walkthrough should succeed even if migration tooling is unavailable or beta behavior changes.

## Demo Environment

Use the provider-light scenario:

```text
terraform/workspace-to-stacks
```

This path uses `terraform_data` resources so the walkthrough can be inspected without AWS, Kubernetes, Helm, or HCP Terraform credentials.

Core component graph:

```text
vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app
```

Key files:

```text
terraform/workspace-to-stacks/workspaces/
terraform/workspace-to-stacks/modules/
terraform/workspace-to-stacks/stack/components.tfcomponent.hcl
terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl
terraform/workspace-to-stacks/component-graph.md
terraform/workspace-to-stacks/migration-map.md
```

## Preflight Commands

Run before recording:

```bash
terraform version
terraform fmt -recursive terraform/workspace-to-stacks
make ci
```

Expected result:

```text
Terraform prints its installed version.
terraform fmt exits cleanly.
make ci completes successfully.
```

Validate representative legacy workspace roots:

```bash
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/vpc validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/eks-cluster init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/eks-cluster validate

terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app validate
```

Expected result:

```text
Success! The configuration is valid.
```

Optional Stacks CLI check:

```bash
terraform -chdir=terraform/workspace-to-stacks/stack stacks init
terraform -chdir=terraform/workspace-to-stacks/stack stacks validate
```

Expected result:

```text
If authenticated and configured correctly, Terraform initializes and validates the Stack.
If this fails because HCP Terraform discovery, auth, or beta behavior is unavailable, use the fallback path and keep the walkthrough focused on the files and mental model.
```

Optional migration tool check:

```bash
tf-migrate version
```

Expected result:

```text
tf-migrate v2.0.0-rc1 or newer
```

Do not use `tf-migrate` in the first walkthrough unless the full beta migration path has already been tested end to end.

## Step-By-Step Recording Plan

### 1. Start With The Old Shape

Show:

```text
terraform/workspace-to-stacks/workspaces
```

Talk track:

> These roots represent the kind of separate HCP Terraform workspaces teams often grow into: network, cluster, platform add-ons, namespace, and application. Each workspace is reasonable alone, but the overall system depends on handoffs between them.

Point out:

- `vpc`
- `eks-cluster`
- `platform-addons`
- `app-namespace`
- `hashibank-app`

Command:

```bash
find terraform/workspace-to-stacks/workspaces -maxdepth 2 -type f | sort
```

Expected output:

```text
terraform/workspace-to-stacks/workspaces/app-namespace/main.tf
terraform/workspace-to-stacks/workspaces/app/main.tf
terraform/workspace-to-stacks/workspaces/eks-cluster/main.tf
terraform/workspace-to-stacks/workspaces/hashibank-app/main.tf
terraform/workspace-to-stacks/workspaces/platform-addons/main.tf
terraform/workspace-to-stacks/workspaces/vpc/main.tf
```

### 2. Name The Operational Pain

Show:

```text
terraform/workspace-to-stacks/migration-map.md
```

Talk track:

> The issue is not that workspaces are bad. The issue is that the dependency graph is implied through outputs, variables, remote state, CI jobs, and runbooks. The platform exists, but Terraform cannot see the whole operating model in one place.

Command:

```bash
sed -n '1,120p' terraform/workspace-to-stacks/migration-map.md
```

Expected point:

- dependencies are visible to the viewer
- the old workflow requires humans, CI, or runbooks to coordinate rollout order

### 3. Show The Modules

Show:

```text
terraform/workspace-to-stacks/modules
```

Talk track:

> Stacks do not replace modules. Modules remain the reusable implementation units. Stacks coordinate those modules across components and deployments.

Command:

```bash
find terraform/workspace-to-stacks/modules -maxdepth 2 -type f | sort
```

Expected output:

```text
terraform/workspace-to-stacks/modules/app-namespace/main.tf
terraform/workspace-to-stacks/modules/app/main.tf
terraform/workspace-to-stacks/modules/eks/main.tf
terraform/workspace-to-stacks/modules/hashibank-app/main.tf
terraform/workspace-to-stacks/modules/platform-addons/main.tf
terraform/workspace-to-stacks/modules/vpc/main.tf
```

### 4. Show The Component Graph

Show:

```text
terraform/workspace-to-stacks/component-graph.md
```

Core graph:

```text
vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app
```

Talk track:

> This is the moment the operational model becomes visible. The app is not just an app. It depends on namespace, add-ons, cluster, and network context.

Command:

```bash
sed -n '1,120p' terraform/workspace-to-stacks/component-graph.md
```

Expected point:

- the graph is understandable without cloud credentials
- dependency context becomes explainable to a human reviewer or an AI assistant

### 5. Show Components

Show:

```text
terraform/workspace-to-stacks/stack/components.tfcomponent.hcl
```

Talk track:

> Components describe the major pieces of the platform and how outputs from one component become inputs to another.

Look for:

- `component "vpc"`
- `component "eks_cluster"`
- `component "platform_addons"`
- `component "app_namespace"`
- `component "hashibank_app"`

Command:

```bash
sed -n '1,220p' terraform/workspace-to-stacks/stack/components.tfcomponent.hcl
```

Expected point:

- component inputs reference outputs from earlier components
- the app component depends on namespace and cluster context
- the Stack makes dependency context explicit

### 6. Show Deployments

Show:

```text
terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl
```

Talk track:

> Deployments answer where this Stack runs. The same component model can be promoted through different deployment contexts with different inputs and approval expectations.

Command:

```bash
sed -n '1,180p' terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl
```

Expected point:

- `dev` and `prod` have different inputs
- development has an auto-approval check
- production keeps approval stricter

### 7. Map To HCP Terraform / TFE

Talk track:

> In production, HCP Terraform or Terraform Enterprise becomes the control plane. It owns state, runs, policy checks, deployment behavior, approvals, audit logs, and workspace or Stack context.

Point to:

```text
docs/stacks-live-prerequisites.md
docs/hcp-terraform-stacks-plan.md
```

Command:

```bash
sed -n '1,120p' docs/stacks-live-prerequisites.md
```

Expected point:

- the local demo is intentionally safe and provider-light
- the live path requires HCP Terraform/TFE access and real credentials
- production demonstrations need stricter recording hygiene

### 8. Bridge To AI-Assisted Review

Ask:

> If this app change modifies replicas, service shape, or namespace assumptions, what is actually in the blast radius?

Talk track:

> This is where Stacks connect to the AI story. The assistant is not applying Terraform. It is using explicit dependency context to explain what changed, what depends on it, and where approval should happen.

Command:

```bash
make agent
```

Expected point:

- the agent can explain and propose
- `mutationExecuted` remains `false`
- this keeps the AI story tied to governed Terraform workflows

## Screen Order

Recommended window order:

1. Terminal in repo root.
2. Editor opened to `terraform/workspace-to-stacks`.
3. `migration-map.md`.
4. `component-graph.md`.
5. `components.tfcomponent.hcl`.
6. `deployments.tfdeploy.hcl`.
7. `docs/stacks-live-prerequisites.md`.
8. Optional terminal output from `make agent`.

Keep the screen calm. This walkthrough is about file shape and mental model, not speed-running commands.

## Exact Command Block

Use this block while recording:

```bash
terraform fmt -recursive terraform/workspace-to-stacks
make ci

find terraform/workspace-to-stacks/workspaces -maxdepth 2 -type f | sort
find terraform/workspace-to-stacks/modules -maxdepth 2 -type f | sort

sed -n '1,120p' terraform/workspace-to-stacks/migration-map.md
sed -n '1,120p' terraform/workspace-to-stacks/component-graph.md
sed -n '1,220p' terraform/workspace-to-stacks/stack/components.tfcomponent.hcl
sed -n '1,180p' terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl

terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app validate

make agent
```

## Expected Outputs

| Step | Expected Output |
| --- | --- |
| `terraform fmt` | exits without changing meaningful files |
| `make ci` | completes successfully |
| `find workspaces` | shows workspace-shaped roots |
| `find modules` | shows reusable module implementations |
| `migration-map.md` | explains old workspace handoffs |
| `component-graph.md` | shows `vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app` |
| `components.tfcomponent.hcl` | shows component references and dependencies |
| `deployments.tfdeploy.hcl` | shows dev/prod deployment differences |
| workspace validate | `Success! The configuration is valid.` |
| `make agent` | proposal requires approval and `mutationExecuted` is `false` |

## Common Mistakes

- Treating Stacks as a replacement for modules.
- Treating every existing workspace as a perfect future component boundary.
- Hiding rollout order in scripts instead of modeling dependencies.
- Making the demo require live cloud credentials too early.
- Letting the AI story distract from the Terraform adoption story.
- Turning the first walkthrough into a beta migration troubleshooting session.

## Recovery / Fallback Path

If Stacks CLI commands fail:

- Do not troubleshoot live unless that is the point of the video.
- Say: "The local walkthrough is focused on the practitioner model. The live HCP Terraform path requires org configuration and auth."
- Continue with `components.tfcomponent.hcl`, `deployments.tfdeploy.hcl`, and `component-graph.md`.

If `tf-migrate` is unavailable or confusing:

- Do not use it in this walkthrough.
- Say: "Workspace-to-Stacks migration is its own workflow and deserves a separate migration-focused video."
- Point to `docs/workspace-to-stacks-beta-migration.md`.

If `make ci` fails:

- Use `terraform fmt -recursive terraform/workspace-to-stacks`.
- Validate only `workspaces/hashibank-app`.
- Keep the recording focused on the Stacks file model.

If `make agent` fails:

- Skip the AI bridge.
- Close with the component graph and HCP Terraform mapping.
- Keep AI-assisted review for the separate Terraform plan review video.

## Should `tf-migrate` Be In This Walkthrough?

Recommendation:

```text
No. Keep it as a future migration-specific episode.
```

Reason:

- This first walkthrough teaches the Stack mental model.
- `tf-migrate` is beta and depends on real HCP Terraform workspace state.
- A migration demo needs its own prerequisites, auth setup, generated files, review steps, and failure modes.
- If migration fails during the first walkthrough, the viewer learns the wrong lesson.

Better future walkthrough:

```text
Migrating HCP Terraform Workspaces To Stacks With tf-migrate
```

That video can focus on:

- prerequisites
- `tf-migrate modules create`
- `tf-migrate stacks prepare`
- `tf-migrate stacks execute`
- generated files
- import behavior
- migration review and rollback plan

## HCP Terraform Adoption Close

Tie the demo back to adoption:

> Stacks are not just a new file format. They are a way to make the operating model visible. Once the component graph is explicit, HCP Terraform and Terraform Enterprise can give teams a stronger control plane for runs, plans, policy, approvals, state, audit, drift, and eventually AI-assisted review.

## Close

> Stacks make the relationships explicit. Once the relationships are explicit, platform teams can reason about deployment order, blast radius, policy, approvals, drift, and eventually AI-assisted review.

## Next Walkthroughs

- Deployment Groups
- Policy and Cost Gates
- Drift Detection and Remediation
- AI Reviews Terraform Plans, Not Applies Them
