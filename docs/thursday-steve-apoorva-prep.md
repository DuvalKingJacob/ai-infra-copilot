# Thursday Steve / Apoorva Prep

This note captures the meeting update and decision asks for the Terraform practitioner companion work.

## Current Status

Runbooks ready for review:

- `docs/building-your-first-terraform-stack-walkthrough.md`
- `docs/detecting-and-remediating-drift-walkthrough.md`
- `docs/video-script-ai-agents-review-terraform-plans.md`
- `docs/video-teleprompter-ai-should-review-terraform-plans.md`

Repo demo paths working:

- Terraform plan review
- Markdown plan review report
- AI-assisted drift triage report
- Sentinel formatting checks
- local authorization checks
- deterministic agent workflow
- read-only `tfctl` context path
- HCP Terraform run-control documentation

## Proposed Series Logic

Use this framing:

```text
Drift is the pain practitioners already understand.
Stacks is the structural answer to orchestration and workspace sprawl.
AI is the assistant layer for review and triage, not a policy authority or apply engine.
```

If Steve's episode order is already fixed, keep the companion order aligned to the series. In live discussion, lead with the practitioner pain so the Stacks walkthrough does not feel like a feature tour.

## Product-Safety Boundaries

- Drift Detection walkthrough is workspace-based.
- Stacks does not have Drift Detection yet.
- Do not say or imply "enable Drift Detection on production Stacks."
- Do not say AI inspects infrastructure directly.
- Say tools retrieve authorized context, and the AI summarizes/classifies/explains that context.
- Sentinel is deterministic policy code written by the platform team.
- AI does not influence Sentinel evaluation.
- AI can explain policy results after HCP Terraform or Terraform Enterprise has evaluated them.
- No autonomous apply is a deliberate accountability boundary, not a limitation to apologize for.

## Key Decision Asks

1. Who owns the Episode 2 companion?

   Likely Jacob, unless reassigned. The companion should cover:

   - Sentinel / OPA policy checks
   - HCP Terraform / TFE policy sets and enforcement levels
   - run tasks for external checks such as cost or security
   - Vault / OIDC dynamic provider credentials
   - where those controls sit between plan and apply

2. Does Steve's Drift episode need revision?

   Stacks does not have Drift Detection yet. If the current lightboard implies Stack-level drift, the script should be adjusted before publishing.

3. Is Episode 9 intentionally deferred?

   Recommendation: yes. The end-to-end orchestration companion should wait until earlier walkthroughs are recorded or at least validated.

4. What records first?

   Recommended order:

   - Stacks walkthrough, centered on before/after HCL
   - workspace-based Drift Detection / remediation workflow
   - AI plan review / drift triage
   - Episode 2 policy/identity/cost companion if assigned

## 60-Second Update

> I have three companion walkthroughs ready for review: Stacks, workspace-based Drift Detection, and AI-assisted plan review/drift triage. The repo has working demo paths for plan review, drift triage, Sentinel formatting, local authorization checks, `tfctl` context, and HCP Terraform run-control documentation.
>
> Bob's SME critique surfaced a few important product-safety edits, and I have been tightening those: Stacks should center on before/after HCL rather than directory listings, Drift should stay workspace-based because Stacks does not have Drift Detection yet, and the AI content needs to separate deterministic Sentinel policy from advisory AI explanation.
>
> The main decisions I need from this meeting are ownership of the Episode 2 companion, confirmation that Episode 9 is intentionally deferred, and alignment on what records first.

## Do Not Say

Avoid:

```text
The AI inspects infrastructure.
```

Say:

```text
Tools retrieve authorized context, and the AI summarizes and classifies that context.
```

Avoid:

```text
Drift Detection works with Stacks.
```

Say:

```text
This Drift walkthrough is workspace-based. Stacks and Drift are adjacent Infrastructure Lifecycle Management topics.
```

Avoid:

```text
AI reviews are like policy checks.
```

Say:

```text
Sentinel is deterministic policy. AI is advisory explanation and triage after policy has evaluated.
```
