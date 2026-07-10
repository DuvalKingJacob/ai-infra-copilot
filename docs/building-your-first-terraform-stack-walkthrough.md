# Building Your First Terraform Stack

This is the first practitioner companion walkthrough for the Terraform Enterprise video series.

The lightboard episode explains why Stacks exist. This walkthrough shows what a practitioner should look at first.

## Objective

Show how a platform team moves from separate workspace-shaped Terraform roots to a Stack with explicit components, deployments, and dependency context.

## Demo Promise

By the end, the viewer should understand:

- why workspace sprawl becomes hard to operate
- how Stacks coordinate modules rather than replacing them
- where components and deployments live
- how dependency context helps review blast radius
- how this maps to HCP Terraform / Terraform Enterprise

## Safe Local Demo

Use the provider-light scenario:

```text
terraform/workspace-to-stacks
```

This path uses `terraform_data` resources so the walkthrough can be inspected without AWS, Kubernetes, Helm, or HCP Terraform credentials.

## Screen Flow

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

### 2. Name The Operational Pain

Show:

```text
terraform/workspace-to-stacks/migration-map.md
```

Talk track:

> The issue is not that workspaces are bad. The issue is that the dependency graph is implied through outputs, variables, remote state, CI jobs, and runbooks. The platform exists, but Terraform cannot see the whole operating model in one place.

### 3. Show The Modules

Show:

```text
terraform/workspace-to-stacks/modules
```

Talk track:

> Stacks do not replace modules. Modules remain the reusable implementation units. Stacks coordinate those modules across components and deployments.

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

### 6. Show Deployments

Show:

```text
terraform/workspace-to-stacks/stack/deployments.tfdeploy.hcl
```

Talk track:

> Deployments answer where this Stack runs. The same component model can be promoted through different deployment contexts with different inputs and approval expectations.

### 7. Map To HCP Terraform / TFE

Talk track:

> In production, HCP Terraform or Terraform Enterprise becomes the control plane. It owns state, runs, policy checks, deployment behavior, approvals, audit logs, and workspace or Stack context.

Point to:

```text
docs/stacks-live-prerequisites.md
docs/hcp-terraform-stacks-plan.md
```

### 8. Bridge To AI-Assisted Review

Ask:

> If this app change modifies replicas, service shape, or namespace assumptions, what is actually in the blast radius?

Talk track:

> This is where Stacks connect to the AI story. The assistant is not applying Terraform. It is using explicit dependency context to explain what changed, what depends on it, and where approval should happen.

## Local Validation

Run:

```bash
terraform fmt -recursive terraform/workspace-to-stacks
make ci
```

Validate a workspace root if needed:

```bash
terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app init -backend=false
terraform -chdir=terraform/workspace-to-stacks/workspaces/hashibank-app validate
```

## Common Mistakes

- Treating Stacks as a replacement for modules.
- Treating every existing workspace as a perfect future component boundary.
- Hiding rollout order in scripts instead of modeling dependencies.
- Making the demo require live cloud credentials too early.
- Letting the AI story distract from the Terraform adoption story.

## Close

> Stacks make the relationships explicit. Once the relationships are explicit, platform teams can reason about deployment order, blast radius, policy, approvals, drift, and eventually AI-assisted review.

## Next Walkthroughs

- Deployment Groups
- Policy and Cost Gates
- Drift Detection and Remediation
- AI Reviews Terraform Plans, Not Applies Them
