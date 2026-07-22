# Terraform Practitioner Backlog

This is a working backlog, not a personal charter.

The goal is to reinforce a clear practitioner lane over time:

> Terraform practitioner adoption, Infrastructure Lifecycle Management, competitive enablement, technical education, and AI-assisted Terraform workflows.

## Priority Backlog

| Topic | Format | Why It Matters | Status |
| --- | --- | --- | --- |
| Why Terraform Stacks Exist | lightboard follow-up / blog | Establishes the problem: workspace sprawl and orchestration limits | planned |
| Building Your First Terraform Stack | practitioner episode | First hands-on walkthrough after Episode 1 | next |
| Adding Policy, Identity, And Cost Gates | practitioner episode | Turns Episode 2 governance into a concrete run lifecycle demo | walkthrough drafted |
| Detecting And Remediating Drift In HCP Terraform | practitioner episode | Turns Episode 3 into an operational workflow | drafted |
| AI Should Review Terraform Plans, Not Apply Them | practitioner episode | Shows AI as reviewer inside governance, not autonomous operator | demo ready |
| Workspace To Stacks Migration | walkthrough / repo demo | Connects legacy workspace reality to Stacks adoption | in progress |
| Deployment Groups | walkthrough | Helps practitioners understand promotion and rollout boundaries | planned |
| Linked Stacks | deep dive | Useful for larger platform architectures and cross-stack dependencies | planned |
| Policy As Code For Stacks | walkthrough | Bridges Episode 2 to actionable Sentinel/OPA usage | planned |
| Run Tasks And Cost Gates | walkthrough | Makes cost governance concrete inside HCP Terraform/TFE | planned |
| AI-Assisted Drift Triage | future demo | Shows how agents could classify, prioritize, and recommend drift remediation at estate scale without bypassing Terraform governance | future |
| `tfctl` For HCP Terraform | short demo | Gives practitioners a CLI path into HCP Terraform workflows | planned |
| Terraform MCP Server | explainer / demo | Connects AI assistants to Terraform context and Registry knowledge | planned |
| AI Authorization For Terraform Tools | deep dive | Shows where external authorization around AI tool access fits | in progress |
| Agent Skills And Terraform Workflows | explainer | Useful if current product positioning validates before recording | needs validation |
| Infragraph And Infrastructure Context | future-looking explainer | Connects dependency context to future AI reasoning | future |
| From Commit To Governed Terraform Run | end-to-end demo | Capstone after earlier walkthroughs exist | future |

## Near-Term Execution

### Next

Produce the first practitioner episode:

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

Draft the second practitioner episode:

```text
Adding Policy, Identity, And Cost Gates
```

Deliverables:

- one-page outline
- HCP Terraform/TFE run lifecycle map
- Sentinel/OPA policy gate
- run task / cost gate
- Vault/OIDC identity boundary
- common mistakes
- recording fallback path

Draft walkthrough:

```text
docs/adding-policy-identity-cost-gates-walkthrough.md
```

Keep this walkthrough workspace-based. Current public feature support lists dynamic credentials for workspaces and Stacks, but policy as code, run tasks, drift detection, and cost optimization for workspaces only.

### Also Drafted

The Drift practitioner episode now has a recording runbook:

```text
docs/detecting-and-remediating-drift-walkthrough.md
```

Use it after the policy/identity/cost walkthrough to show another Infrastructure Lifecycle Management workflow before going deeper on AI.

Scope note:

```text
This is a workspace-based Drift Detection walkthrough, not a Stacks drift demo.
```

### Later

Use the practitioner episode roadmap to decide the next walkthrough based on team needs:

- drift detection/remediation
- AI plan review
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
