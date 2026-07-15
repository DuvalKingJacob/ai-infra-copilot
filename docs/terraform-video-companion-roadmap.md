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
| Episode 2: Identity, Policy, and Cost | Governance should scale with the estate, not become a bottleneck | Adding Policy, Identity, and Cost Gates | likely Jacob |
| Episode 3: Drift Detection and Remediation | Drift turns declared infrastructure into fiction unless it is detected and reviewed | Detecting and Remediating Drift in HCP Terraform | walkthrough drafted |
| Episode 8: The AI Estate | AI agents need Terraform context, domain knowledge, identity, policy, and audit boundaries | AI Reviews Terraform Plans, Not Applies Them | already started in this repo |
| Episode 9: Grand Orchestration | The platform story is strongest when all lifecycle layers work together | From Commit to Governed Terraform Run | recommended after earlier walkthroughs |

## Practitioner Curriculum

The companion roadmap should follow the practitioner journey, not a one-to-one episode count. Companion walkthroughs should attach only where a practitioner needs a concrete demo path after the strategic explanation.

```text
Build   -> Building Your First Terraform Stack
Govern  -> Adding Policy, Identity, and Cost Gates
Manage  -> Detecting and Remediating Drift in HCP Terraform
Operate -> AI Reviews Terraform Plans, Not Applies Them
Scale   -> From Commit to Governed Terraform Run
```

| Episode | Overview Topic | Companion Decision | Why |
| --- | --- | --- | --- |
| 1 | Beyond the Workspace / Stacks | add companion | Stacks adoption needs a hands-on file-shape and workflow walkthrough. |
| 2 | Identity, Policy, and Cost | add companion | Practitioners need to see where policy sets, run tasks, and dynamic credentials sit in the run lifecycle. |
| 3 | Drift Detection and Remediation | add companion | Drift is operationally familiar and benefits from a reviewed remediation workflow demo. |
| 4 | Terraform Actions and Event-Driven Workflows | defer companion | Add later only if the Actions episode needs a concrete day-2 runbook demo. |
| 5 | Terraform + Ansible Automation Platform | no immediate companion | This is a hybrid integration story; keep the Terraform companions focused first. |
| 6 | Packer / Waypoint / TDP | removed from current series scope | Removed from the current roadmap to reflect product priorities. |
| 7 | IBM Turbonomic | no immediate companion | This is optimization/right-sizing content and should not distract from Terraform adoption walkthroughs. |
| 8 | AI Estate | add companion | This repo already demonstrates AI-assisted Terraform plan review and drift triage inside governance boundaries. |
| 9 | Grand Orchestration | defer companion | Strong final scenario, but only after the earlier building blocks are validated. |

Recommended companion order:

1. Building Your First Terraform Stack.
2. Adding Policy, Identity, and Cost Gates.
3. Detecting and Remediating Drift in HCP Terraform.
4. AI Reviews Terraform Plans, Not Applies Them.
5. From Commit to Governed Terraform Run.

Do not try to create companion videos for every lightboard episode. The companion lane should stay practitioner-first and demo-led. If a topic is removed from the active product/content roadmap, remove it from the companion plan rather than carrying it as a placeholder.

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
- Likely owner: Jacob, unless Steve/Apoorva assign otherwise.
- Avoid making this Stacks-specific until the exact policy input shape and current product support are validated.
- Known script correction to validate with Steve/Apoorva: `import "tfstack"` appears to be illustrative shorthand, not a real current Stacks Sentinel import. Do not build the Episode 2 companion around it unless Product confirms current support.

### Episode 3: Drift

- Good practitioner follow-up because drift has obvious operational stakes.
- Keep expectations precise: drift detection is scheduled/refresh-based, not real-time streaming.
- Companion walkthrough should show drift as a reviewed remediation workflow, not auto-apply.
- Keep this walkthrough workspace-based. Stacks does not have Drift Detection yet, so do not imply Stack-level drift support.
- A future AI companion could show estate-scale drift triage: classify drift, prioritize risk, recommend remediation paths, and hand off any change to Terraform approvals instead of letting an agent fix drift directly.
- Draft walkthrough: `docs/detecting-and-remediating-drift-walkthrough.md`

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

Stacks make relationships explicit. Once those relationships are explicit, teams can reason about deployment order, blast radius, policy, approvals, and eventually AI-assisted review. Drift Detection should be handled as a separate workspace-based companion walkthrough.
