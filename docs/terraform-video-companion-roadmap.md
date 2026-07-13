# Terraform Video Companion Roadmap

This roadmap defines Jacob's practitioner companion lane for the Terraform Enterprise video series.

The lightboard episodes explain why the capability matters. The companion walkthroughs should show how practitioners would actually use it.

## Learning Model

The series should help someone move through four stages:

1. Understand the operational problem.
2. Learn the Terraform Enterprise / HCP Terraform capability that addresses it.
3. See the capability in a realistic practitioner workflow.
4. Know what to try next in their own environment.

The companion videos should be tactical, demo-first, and grounded in Terraform practitioner work. They should avoid re-explaining the full lightboard narrative.

## Companion Map

| Lightboard Episode | Core Message | Companion Walkthrough | Status |
| --- | --- | --- | --- |
| Episode 1: Beyond the Workspace | Stacks move teams from workspace sprawl to dependency-aware orchestration | Building Your First Terraform Stack | recommended |
| Episode 2: Identity, Policy, and Cost | Governance should scale with the estate, not become a bottleneck | Adding Policy and Cost Gates to a Stack | recommended |
| Episode 3: Drift Detection and Remediation | Drift turns declared infrastructure into fiction unless it is detected and reviewed | Detecting and Remediating Drift in HCP Terraform | recommended |
| Episode 8: The AI Estate | AI agents need Terraform context, domain knowledge, identity, policy, and audit boundaries | AI Reviews Terraform Plans, Not Applies Them | already started in this repo |
| Episode 9: Grand Orchestration | The platform story is strongest when all lifecycle layers work together | From Commit to Governed Terraform Run | recommended after earlier walkthroughs |

## Review Notes For Owned Episodes

These are TPMM/SME notes to consider when reviewing the scripts. They are not rewrites.

### Episode 1: Stacks

- Keep the distinction between Terraform CLI workspaces and HCP Terraform/TFE workspaces concise; it is useful, but the main story is orchestration.
- Consider using "workspace sprawl" as the practitioner pain phrase, then showing the concrete operational symptoms: remote state handoffs, manual sequencing, stale outputs, one-plan-at-a-time review.
- Companion walkthrough should show actual files: modules, components, deployments, and dependency graph.
- Avoid implying Stacks replace modules. The strongest line is: Stacks coordinate modules across deployments.

### Episode 2: Policy, Identity, And Cost

- Strong companion candidate because practitioners will want to see where policy sets, enforcement levels, run tasks, and dynamic credentials actually sit in the run lifecycle.
- Be careful with claims about unified plan JSON and exact Stack policy input shape; validate against current docs before recording.
- The practical walkthrough should separate three layers: Sentinel/OPA policy checks, run tasks for external checks, and Vault/OIDC identity.
- The "speed vs safety" framing is strong; the companion should show the gate, not just describe it.

### Episode 3: Drift

- Good practitioner follow-up because drift has obvious operational stakes.
- Keep expectations precise: drift detection is scheduled/refresh-based, not real-time streaming.
- Companion walkthrough should show drift as a reviewed remediation workflow, not auto-apply.
- Connect drift to Stack/component health if the product supports the exact view being shown in the demo.
- A future AI companion could show estate-scale drift triage: classify drift, prioritize risk, recommend remediation paths, and hand off any change to Terraform approvals instead of letting an agent fix drift directly.

### Episode 8: AI Estate

- This maps directly to the AI repo.
- The clean practitioner hook is: AI should review Terraform plans inside HCP Terraform/TFE governance, not bypass it.
- MCP and Skills should be framed as context and domain knowledge, not as governance.
- The companion should show plan review, policy signals, authorization, and approval boundaries.
- Validate current status and positioning of Agent Skills, MCP Server, and Project Infragraph before recording.

### Episode 9: Grand Orchestration

- This should probably not get a companion walkthrough until the earlier building blocks are recorded.
- Companion should become a scenario demo: PR -> speculative plan -> policy/run task checks -> Stack apply -> action/remediation/audit.
- It may be the strongest "executive/practitioner bridge" asset, but it needs the most setup.

## First Companion To Produce

Start with:

> Building Your First Terraform Stack

Why:

- It directly supports Episode 1.
- It builds from the existing HashiConf talk.
- It uses the repo's workspace-to-Stacks scenario.
- It creates the foundation for deployment groups, drift, AI review, and the final orchestration story.

Detailed walkthrough:

```text
docs/building-your-first-terraform-stack-walkthrough.md
```

## One-Page Outline: Building Your First Terraform Stack

### Objective

Show how a practitioner moves from separate workspace-shaped Terraform roots to a Stack with explicit components and deployments.

### Prerequisites

- Terraform installed.
- HCP Terraform / TFE access for the live path.
- Local repo for the provider-light walkthrough.
- Optional HashiBank companion repo for a real AWS/Kubernetes implementation.

### Demo Environment

Local safe path:

```text
terraform/workspace-to-stacks
```

Component graph:

```text
vpc -> eks_cluster -> platform_addons -> app_namespace -> hashibank_app
```

### Architecture

Old model:

```text
workspace -> workspace -> workspace -> workspace
```

New model:

```text
Stack
  components
  deployments
  deployment groups
  shared dependency context
```

### Walkthrough

1. Show the old workspace roots.
2. Explain the operational problem: state handoffs, sequencing, and review fragmentation.
3. Show the module directories.
4. Show the component configuration.
5. Show the deployment configuration.
6. Show the component graph.
7. Explain how this maps to HCP Terraform / TFE.
8. Show what a practitioner should validate before going live.

### Common Mistakes

- Treating Stacks as a module replacement.
- Trying to copy every workspace directly without redesigning boundaries.
- Hiding dependency context in scripts instead of modeling it.
- Mixing real org IDs, account IDs, ARNs, or state into public demos.
- Letting the AI angle distract from the Terraform adoption story.

### Wrap-Up

Stacks make relationships explicit. Once those relationships are explicit, teams can reason about deployment order, blast radius, policy, approvals, drift, and eventually AI-assisted review.
