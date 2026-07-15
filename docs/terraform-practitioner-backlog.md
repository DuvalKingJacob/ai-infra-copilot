# Terraform Practitioner Backlog

This is a working backlog, not a personal charter.

The goal is to reinforce a clear practitioner lane over time:

> Terraform practitioner adoption, Infrastructure Lifecycle Management, competitive enablement, technical education, and AI-assisted Terraform workflows.

## Priority Backlog

| Topic | Format | Why It Matters | Status |
| --- | --- | --- | --- |
| Why Terraform Stacks Exist | lightboard companion / blog | Establishes the problem: workspace sprawl and orchestration limits | planned |
| Building Your First Terraform Stack | walkthrough | First hands-on companion to Episode 1 | next |
| Workspace To Stacks Migration | walkthrough / repo demo | Connects legacy workspace reality to Stacks adoption | in progress |
| Deployment Groups | walkthrough | Helps practitioners understand promotion and rollout boundaries | planned |
| Linked Stacks | deep dive | Useful for larger platform architectures and cross-stack dependencies | planned |
| Policy As Code For Stacks | walkthrough | Bridges Episode 2 to actionable Sentinel/OPA usage | planned |
| Run Tasks And Cost Gates | walkthrough | Makes cost governance concrete inside HCP Terraform/TFE | planned |
| Drift Detection | walkthrough | Turns Episode 3 into an operational workflow | drafted |
| Drift Remediation | walkthrough | Shows review/approval boundaries for fixing drift | drafted |
| AI-Assisted Drift Triage | future demo | Shows how agents could classify, prioritize, and recommend drift remediation at estate scale without bypassing Terraform governance | future |
| `tfctl` For HCP Terraform | short demo | Gives practitioners a CLI path into HCP Terraform workflows | planned |
| Terraform MCP Server | explainer / demo | Connects AI assistants to Terraform context and Registry knowledge | planned |
| AI Reviews Terraform Plans | walkthrough | Shows AI as reviewer inside governance, not autonomous operator | in progress |
| AI Authorization For Terraform Tools | deep dive | Shows where external authorization around AI tool access fits | in progress |
| Agent Skills And Terraform Workflows | explainer | Useful if current product positioning validates before recording | needs validation |
| Infragraph And Infrastructure Context | future-looking explainer | Connects dependency context to future AI reasoning | future |
| From Commit To Governed Terraform Run | end-to-end demo | Companion to Episode 9 after earlier walkthroughs exist | future |

## Near-Term Execution

### Next

Produce the first companion walkthrough:

```text
Building Your First Terraform Stack
```

Deliverables:

- one-page outline
- demo flow
- terminal commands
- screen recording checklist
- common mistakes
- short call to action

### Then

Turn the AI repo into a repeatable Terraform practitioner demo:

```text
AI Reviews Terraform Plans, Not Applies Them
```

Deliverables:

- validated README
- 5-7 minute teleprompter
- safe local demo
- risky plan demo
- HCP Terraform/TFE mapping
- authorization and approval explanation

### Also Drafted

The Drift companion walkthrough now has a recording runbook:

```text
docs/detecting-and-remediating-drift-walkthrough.md
```

Use it next to the Stacks foundation to show another Infrastructure Lifecycle Management workflow before going deeper on AI.

Scope note:

```text
This is a workspace-based Drift Detection walkthrough, not a Stacks drift demo.
```

### Later

Use the companion roadmap to decide the next walkthrough based on team needs:

- policy and cost gates
- drift detection/remediation
- AI-assisted drift triage at scale
- deployment groups
- `tfctl`
- MCP

## Future Demo: AI-Assisted Drift Triage

This is a future extension of the same reference architecture, not a replacement for the current plan-review demo.

Scenario:

- An enterprise estate has hundreds or thousands of workspaces.
- Drift detection surfaces a large set of drift events.
- Platform teams need to know which events are cosmetic, which are risky, which teams own them, and which remediation path is appropriate.

Workflow:

1. HCP Terraform or Terraform Enterprise detects drift.
2. An authorized agent gathers read-only context such as workspace, project, owner, environment, resource type, previous runs, policy history, and available run metadata.
3. The agent classifies drift into buckets such as cosmetic, configuration drift, security drift, critical production drift, and requires investigation.
4. The agent recommends a next step: ignore, investigate, import, plan remediation, or escalate to platform/security.
5. Humans approve any remediation path.
6. Terraform remains the execution and audit control point.

Why it matters:

- It turns drift from a notification problem into a prioritization workflow.
- It gives practitioners a concrete reason to care about Terraform context, workspace ownership, policy history, and approval boundaries.
- It reinforces the core AI operating model: agents can collect context, classify risk, and propose action, but governed Terraform workflows should execute infrastructure change.

## Operating Principle

Every asset should answer:

> Why should a Terraform practitioner care, and what can they try next?

Avoid feature tours. Start with the operational pain, then show the Terraform workflow that addresses it.
