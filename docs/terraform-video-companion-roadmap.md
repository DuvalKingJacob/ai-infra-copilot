# Terraform Practitioner Episode Roadmap

This roadmap defines Jacob's practitioner walkthrough lane for the Terraform Enterprise video series.

The lightboard episodes explain why the capability matters. The practitioner episodes should show how Terraform users would actually implement the workflow.

## Learning Model

The series should help someone move through four stages:

1. Understand the operational problem.
2. Learn the Terraform Enterprise / HCP Terraform capability that addresses it.
3. See the capability in a realistic practitioner workflow.
4. Know what to try next in their own environment.

The practitioner episodes should be tactical, demo-first, and grounded in Terraform practitioner work. They should avoid re-explaining the full lightboard narrative.

## Practitioner Episode Map

| Lightboard Episode | Core Message | Practitioner Episode | Status |
| --- | --- | --- | --- |
| Episode 1: Beyond the Workspace | Stacks move teams from workspace sprawl to dependency-aware orchestration | Building Your First Terraform Stack | first |
| Episode 2: Identity, Policy, and Cost | Governance should scale with the estate, not become a bottleneck | Adding Policy, Identity, and Cost Gates | second |
| Episode 3: Drift Detection and Remediation | Drift turns declared infrastructure into fiction unless it is detected and reviewed | Detecting and Remediating Drift in HCP Terraform | walkthrough drafted |
| Episode 8: The AI Estate | AI agents need Terraform context, domain knowledge, identity, policy, and audit boundaries | AI Should Review Terraform Plans, Not Apply Them | demo ready; script lives in Word |
| Episode 9: Grand Orchestration | The platform story is strongest when all lifecycle layers work together | From Commit to Governed Terraform Run | recommended after earlier walkthroughs |

## Execution Order

Do not add new episodes until these four are easy to explain, record, and hand off:

1. Building Your First Terraform Stack.
2. Adding Policy, Identity, and Cost Gates.
3. Detecting and Remediating Drift in HCP Terraform.
4. AI Should Review Terraform Plans, Not Apply Them.

## Practitioner Curriculum

The practitioner roadmap should follow the implementation journey, not a one-to-one response to every lightboard. Add hands-on episodes only where a practitioner needs a concrete demo path after the strategic explanation.

```text
Build   -> Building Your First Terraform Stack
Govern  -> Adding Policy, Identity, and Cost Gates
Manage  -> Detecting and Remediating Drift in HCP Terraform
Operate -> AI Should Review Terraform Plans, Not Apply Them
Scale   -> From Commit to Governed Terraform Run
```

| Episode | Overview Topic | Practitioner Episode Decision | Why |
| --- | --- | --- | --- |
| 1 | Beyond the Workspace / Stacks | add practitioner episode | Stacks adoption needs a hands-on file-shape and workflow walkthrough. |
| 2 | Identity, Policy, and Cost | add practitioner episode | Practitioners need to see where policy sets, run tasks, and dynamic credentials sit in the run lifecycle. |
| 3 | Drift Detection and Remediation | add practitioner episode | Drift is operationally familiar and benefits from a reviewed remediation workflow demo. |
| 4 | Terraform Actions and Event-Driven Workflows | defer practitioner episode | Add later only if the Actions episode needs a concrete day-2 runbook demo. |
| 5 | Terraform + Ansible Automation Platform | no immediate practitioner episode | This is a hybrid integration story; keep the Terraform practitioner episodes focused first. |
| 6 | Packer / Waypoint / TDP | removed from current series scope | Removed from the current roadmap to reflect product priorities. |
| 7 | IBM Turbonomic | no immediate practitioner episode | This is optimization/right-sizing content and should not distract from Terraform adoption walkthroughs. |
| 8 | AI Estate | add practitioner episode | This repo demonstrates AI-assisted Terraform plan review and drift triage inside governance boundaries. |
| 9 | Grand Orchestration | defer practitioner episode | Strong final scenario, but only after the earlier building blocks are validated. |

Recommended practitioner episode order:

1. Building Your First Terraform Stack.
2. Adding Policy, Identity, and Cost Gates.
3. Detecting and Remediating Drift in HCP Terraform.
4. AI Should Review Terraform Plans, Not Apply Them.
5. From Commit to Governed Terraform Run.

Do not try to create practitioner videos for every lightboard episode. The walkthrough lane should stay practitioner-first and demo-led. If a topic is removed from the active product/content roadmap, remove it from the plan rather than carrying it as a placeholder.

## Review Notes For Owned Episodes

These are TPMM/SME notes to consider when reviewing the scripts. They are not rewrites.

### Episode 1: Stacks

- Keep the distinction between Terraform CLI workspaces and HCP Terraform/TFE workspaces concise; it is useful, but the main story is orchestration.
- Consider using "workspace sprawl" as the practitioner pain phrase, then showing the concrete operational symptoms: remote state handoffs, manual sequencing, stale outputs, one-plan-at-a-time review.
- Practitioner walkthrough should show actual files: modules, components, deployments, and dependency graph.
- Avoid implying Stacks replace modules. The strongest line is: Stacks coordinate modules across deployments.

### Episode 2: Policy, Identity, And Cost

- Strong practitioner episode candidate because users will want to see where policy sets, enforcement levels, run tasks, and dynamic credentials actually sit in the run lifecycle.
- Be careful with claims about unified plan JSON and exact Stack policy input shape; validate against current docs before recording.
- The practical walkthrough should separate three layers: Sentinel/OPA policy checks, run tasks for external checks, and Vault/OIDC identity.
- The "speed vs safety" framing is strong; the practitioner episode should show the gate, not just describe it.
- Likely owner: Jacob, unless Steve/Apoorva assign otherwise.
- Avoid making this Stacks-specific until the exact policy input shape and current product support are validated.
- Known script correction to validate with Steve/Apoorva: `import "tfstack"` appears to be illustrative shorthand, not a real current Stacks Sentinel import. Do not build the Episode 2 practitioner episode around it unless Product confirms current support.
- Current public feature support lists policy as code and run tasks for workspaces, not Stacks. Build the companion around the `ai-infra-copilot` workspace and treat the draft's Stack-wide policy and run-task claims as corrections for SME review.
- Draft walkthrough: `docs/adding-policy-identity-cost-gates-walkthrough.md`

### Episode 3: Drift

- Good practitioner follow-up because drift has obvious operational stakes.
- Keep expectations precise: drift detection is scheduled/refresh-based, not real-time streaming.
- Practitioner walkthrough should show drift as a reviewed remediation workflow, not auto-apply.
- Keep this walkthrough workspace-based. Stacks does not have Drift Detection yet, so do not imply Stack-level drift support.
- A future AI practitioner episode could show estate-scale drift triage: classify drift, prioritize risk, recommend remediation paths, and hand off any change to Terraform approvals instead of letting an agent fix drift directly.
- Draft walkthrough: `docs/detecting-and-remediating-drift-walkthrough.md`

### Episode 8: AI Estate

- This maps directly to the AI repo.
- The clean practitioner hook is: AI should review Terraform plans inside HCP Terraform/TFE governance, not bypass it.
- MCP and Skills should be framed as context and domain knowledge, not as governance.
- The practitioner episode should show plan review, policy signals, authorization, and approval boundaries.
- Validate current status and positioning of Agent Skills, MCP Server, and Project Infragraph before recording.

### Episode 9: Grand Orchestration

- This should probably not get a practitioner walkthrough until the earlier building blocks are recorded.
- The walkthrough should become a scenario demo: PR -> speculative plan -> policy/run task checks -> Stack apply -> action/remediation/audit.
- It may be the strongest "executive/practitioner bridge" asset, but it needs the most setup.

## First Practitioner Episode To Produce

Start with:

> Building Your First Terraform Stack

Why:

- It directly supports Episode 1.
- It builds from the existing HashiConf talk.
- It uses the HashiBank Stacks repo as the primary practitioner demo.
- It keeps this repo's workspace-to-Stacks scenario as the safe fallback and teaching scaffold.
- It creates the foundation for deployment groups, drift, AI review, and the final orchestration story.
- It avoids making the first Stacks episode depend on `tf-migrate` or a beta migration workflow.

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
- Local clone of the HashiBank Stacks repo for the primary walkthrough.
- This repo's provider-light Stacks scaffold for fallback recording.
- `tf-migrate` only for a future migration-specific walkthrough.

### Demo Environment

Primary practitioner path:

```text
/Users/jacobplicque/Projects/tfstacks-vpc-eks-hashibank
```

Fallback safe path:

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

1. Show why workspace-shaped roots become hard to coordinate.
2. Explain the operational problem: state handoffs, sequencing, and review fragmentation.
3. Show the HashiBank component directories: VPC, EKS, Kubernetes RBAC, add-ons, namespace, and app deployment.
4. Show `components.tfcomponent.hcl` as the spine of the video.
5. Show `deployments.tfdeploy.hcl` for dev/prod deployment behavior.
6. Show the component graph and how outputs move between components.
7. Explain how this maps to HCP Terraform / TFE.
8. Use this repo's provider-light scaffold only if the live HashiBank path is not screen-safe.
9. Show what a practitioner should validate before going live.

### Common Mistakes

- Treating Stacks as a module replacement.
- Trying to copy every workspace directly without redesigning boundaries.
- Hiding dependency context in scripts instead of modeling it.
- Mixing real org IDs, account IDs, ARNs, or state into public demos.
- Letting the AI angle distract from the Terraform adoption story.
- Starting with `tf-migrate` before the Stack mental model is clear.

### Wrap-Up

Stacks make relationships explicit. Once those relationships are explicit, teams can reason about deployment order, blast radius, policy, approvals, and eventually AI-assisted review. The first practitioner episode should teach that model through HashiBank. Workspace migration and Drift Detection should be handled as separate practitioner episodes.
