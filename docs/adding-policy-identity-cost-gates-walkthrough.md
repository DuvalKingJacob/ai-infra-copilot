# Adding Policy, Identity, And Cost Gates

## Purpose

This is the practitioner companion to Episode 2, `Guarding the Estate - Identity, Policy, and Cost`.

The lightboard explains why governance must scale with infrastructure delivery. This walkthrough shows how a practitioner adds three distinct controls to an HCP Terraform run:

1. Dynamic provider credentials establish which cloud identity Terraform uses.
2. Sentinel or OPA evaluates deterministic infrastructure rules.
3. Cost estimation and optional run tasks add financial or external governance signals.

The controls meet in one governed run, but they do different jobs.

## Product Boundary

Use an HCP Terraform **workspace** for this walkthrough.

Current public HCP Terraform feature documentation lists dynamic provider credentials for both workspaces and Stacks. It lists policy as code, run tasks, drift detection, and cost optimization for workspaces, but not for Stacks.

Do not present this as Stack-level policy enforcement. Do not use an illustrative `import "tfstack"` policy. Do not claim that Stacks produce one unified plan JSON for policy evaluation.

This gives the series a useful progression:

```text
Episode 1 companion: Stacks for dependency-aware orchestration
Episode 2 companion: Workspaces for the currently supported governance workflow
```

## Learning Objectives

By the end, viewers should be able to:

- explain where identity, policy, cost, and human approval sit in a Terraform run
- distinguish dynamic credentials from stored cloud secrets
- distinguish Sentinel/OPA policy checks from external run tasks
- identify advisory, overridable, and mandatory governance behavior without treating every signal as identical
- explain why an external integration does not replace Terraform policy or human accountability
- create a safe review-only demonstration that never applies the intentionally risky change

## Core Mental Model

```text
Developer commit
      |
      v
HCP Terraform workspace
      |
      +--> OIDC workload identity --> temporary AWS credentials
      |
      v
Terraform plan
      |
      +--> native cost estimate
      +--> Sentinel or OPA policy checks
      +--> optional post-plan run task
      |
      v
Human-controlled apply boundary
```

Say explicitly:

> Identity determines what Terraform can access. Policy determines whether the proposed infrastructure is acceptable. Cost provides financial context or a financial gate. Human approval determines whether an allowed change should proceed now.

## Demo Scenario

Use the existing HCP Terraform workspace:

```text
ai-infra-copilot
```

Use the Terraform root module:

```text
terraform/app-platform
```

The scenario models a payments platform with:

- an ECS cluster and service
- an application load balancer
- an RDS database
- a latency alarm
- production ownership tags

The risky plan proposes:

- an internet-facing load balancer
- production service capacity of one
- missing `Environment` and `Owner` tags
- apply-sensitive runtime resources

The run is for review only. Do not apply the risky plan.

## Recommended V1 Scope

Show these capabilities live:

- HCP Terraform remote run
- AWS dynamic provider credentials through OIDC
- HCP Terraform cost estimation
- Sentinel policy results
- human approval boundary

Treat a third-party cost run task as optional until a real integration and endpoint are available. Do not simulate IBM Cloudability and describe it as a product integration.

If a real run task is available, show it as a separate post-plan gate. Explain that HCP Terraform sends run metadata and authorized API links to the external service, which evaluates the run and returns a result. Do not say the webhook payload is simply the complete plan JSON.

## Live Workspace Audit - July 22, 2026

The `ai-infra-copilot` workspace currently has:

- repository: `DuvalKingJacob/ai-infra-copilot`
- working directory: `terraform/app-platform`
- execution mode: Remote
- Terraform version: 1.15.8
- auto-apply: off
- auto-destroy: off
- organization-wide cost estimation: enabled
- organization-wide Sentinel policy set: `AWS_Policies`
- existing global cost policy: `aws-costing.sentinel`, running in the HCP Terraform Agent execution environment
- workspace-scoped Sentinel policy set: `ai-infra-governance`
- workspace policy: `require-prod-tags`, soft-mandatory
- run tasks: none configured
- AWS dynamic credential set: active
- static AWS access-key variables: removed
- AWS run role: dedicated to this workspace and limited to read-only access

The canonical governance validation run is:

```text
run-8ewJgjxUkTDQKgwv
```

HCP Terraform completed a standard plan with auto-apply disabled and identified two resources to create. AWS dynamic OIDC credentials were used successfully — no static access keys were present in the workspace. Native cost estimation completed at +$0.30/month (safe defaults: runtime resources disabled, only the ECS cluster and CloudWatch alarm planned). The workspace-scoped `ai-infra-governance/require-prod-tags` policy failed intentionally because the prepared `common_tags` variable omitted `Owner`. An authorized reviewer overrode the soft-mandatory failure with a validation-only comment; the run timeline preserved the reviewer identity, timestamp, and decision. The run reached the confirmation boundary and was discarded. No infrastructure was applied.

The existing `AWS_Policies` set is not a valid cost-threshold demonstration for this walkthrough. It uses the HCP Terraform Agent execution environment, which does not receive cost-estimation data. Its policy substitutes `1000.0` when `tfrun.cost_estimate` is null, so any failure from that set does not mean the actual $0.30 estimate exceeded the $100 threshold. Do not narrate it as a legitimate cost-policy failure.

Prior validation runs for troubleshooting context:

- `run-8JNbGjio2Sd4xNe4`: standard plan, OIDC confirmed, cost estimation at +$0.30/month, `require-prod-tags` passed (default `common_tags` satisfied all tags), org cost policy overridden to reach later phases, discarded before apply.
- `run-dMbCC7iEo9yiDtmg`: OIDC-only validation after static keys were removed. Reported `Errored` due to the org-wide cost policy failing at the policy phase — not an identity failure.

For a clean recording, exclude only the `ai-infra-copilot` workspace from the legacy global policy set and use the workspace-scoped policy as the deliberate failure. Do not change the global policy set's execution mode solely for this demo; that would affect every workspace in the organization.

This is the desired teaching sequence:

1. OIDC establishes a temporary AWS identity.
2. Terraform successfully creates the plan.
3. Native cost estimation exposes the plan's actual financial signal.
4. The workspace-scoped `require-prod-tags` policy fails because the prepared `common_tags` value intentionally omits `Owner`.
5. An authorized reviewer overrides the soft-mandatory failure with a validation-only comment; the run timeline preserves the reviewer and decision.
6. The human confirmation boundary and explicit discard prevent apply.

The repository contains `policies/sentinel/sentinel.hcl`, which publishes only `require-prod-tags` as a soft-mandatory demo policy. The VCS-backed `ai-infra-governance` policy set is scoped to this workspace and was validated in the canonical run. This separates platform tagging governance from the existing global cost policy.

### Prepared Recording Variable

Create a temporary, non-sensitive Terraform variable named `common_tags` in the workspace, enable HCL parsing, and use:

```hcl
{
  Service     = "payments-api"
  Environment = "prod"
  ManagedBy   = "terraform"
}
```

The missing `Owner` tag causes the workspace-scoped policy to fail for an explainable reason. After recording, delete this workspace override so the configuration returns to its safe defaults.

## Prerequisites

- HCP Terraform workspace connected to the repository
- workspace working directory set to `terraform/app-platform`
- AWS dynamic provider credentials configured for the workspace
- a dedicated AWS plan role with enough read access to refresh and plan the demo resources
- AWS trust policy scoped to the intended HCP Terraform organization, project, workspace, and run phases
- cost estimation enabled for the organization
- Sentinel policy set attached to the workspace or its project
- VCS policy path set to `policies/sentinel` and scoped to the intended workspace or project
- permission to start standard runs and inspect policy results
- a prepared risky-plan commit or workspace-variable change
- no static AWS access keys visible in the workspace variables screen

Optional:

- a real cost or security run task associated with the workspace
- a safe baseline run captured before the risky run

To recreate the workspace policy set in the HCP Terraform UI:

1. Open **Organization Settings > Policy sets > Create policy set**.
2. Select **Sentinel** and a VCS-backed source.
3. Select this repository and set the policies path to `policies/sentinel`.
4. Scope the set to the `ai-infra-copilot` workspace or its project.
5. Use the platform execution environment and verify that the next run shows `ai-infra-governance` as a separate policy phase.

The enforcement level comes from `sentinel.hcl`; the demo policy is `soft-mandatory` so only a reviewer with policy-override permission can advance a failure.

## Preflight

Local checks:

```bash
cd ai-infra-copilot
make validate
terraform -chdir=terraform/app-platform validate
git status --short
```

HCP Terraform checks:

```bash
tfctl auth status
tfctl api /workspaces/{workspace}/vars -p workspace=ai-infra-copilot --jq '.data[] | {key: .attributes.key, category: .attributes.category, sensitive: .attributes.sensitive}'
tfctl api /workspaces/{workspace}/runs -p workspace=ai-infra-copilot --page-size 5 --jq '.data[] | {id, status: .attributes.status, message: .attributes.message}'
```

The variable check intentionally prints metadata only. Never print credential values during recording.

Confirm in the UI:

- the VCS repository and working directory are correct
- dynamic credentials are configured for AWS
- the intended policy set is in scope
- cost estimation is enabled and appears in a recent run
- any optional run task is attached at the intended stage and enforcement level
- auto-apply is disabled for the risky demo
- the `ai-infra-copilot` workspace is excluded from the legacy `AWS_Policies` set
- the temporary `common_tags` variable omits only `Owner`

`run-8ewJgjxUkTDQKgwv` is the fallback artifact if a fresh run is unavailable during recording.

## Recording Plan

### 1. Open With The Run Lifecycle

Start on a completed HCP Terraform run, not on a slide.

Say:

> A governed Terraform run is not one giant security feature. It is a sequence of controls. Identity establishes what the run can do, policy evaluates what the plan proposes, cost makes the financial impact visible, and approval preserves human accountability.

### 2. Show Identity Before Infrastructure

Open the workspace dynamic credential configuration or a sanitized architecture diagram.

Show:

- HCP Terraform as the OIDC issuer
- the AWS role trusted by the workspace
- temporary credentials created for the run
- plan and apply identities if separate roles are configured

Do not show account IDs, role ARNs, tokens, or variable values.

Say:

> Terraform is not pulling a long-lived AWS key from a shared variable. HCP Terraform presents a signed workload identity to AWS, receives temporary credentials, and discards them with the run environment.

> For AWS, HCP Terraform issues a run-specific OIDC token and exchanges it through STS `AssumeRoleWithWebIdentity`. The IAM role trust policy constrains the token subject to the intended HCP Terraform organization, project, workspace, and run phase.

### 3. Show The Risky Terraform Change

Open:

```text
terraform/app-platform/main.tf
terraform/app-platform/risky.tfvars.example
```

Call out the operational risks rather than reading every resource:

- public exposure
- reduced capacity
- missing ownership metadata
- cost-bearing runtime resources

Say:

> The policy engine is not guessing whether this looks risky. It evaluates explicit rules against the Terraform plan.

### 4. Start A Governed Standard Run

Use the prepared `common_tags` workspace variable and start a standard plan from the HCP Terraform UI. Keep auto-apply disabled. A speculative plan cannot demonstrate the authorized override and confirmation boundary used in this walkthrough.

If using `tfctl`:

```bash
tfctl run start ai-infra-copilot
tfctl run status ai-infra-copilot
```

Do not start a run until the working directory and exact configuration revision have been checked.

### 5. Show The Cost Surface

Open the cost estimation phase and show:

- estimated monthly total
- estimated monthly delta
- resources HCP Terraform could not estimate

Say:

> Cost estimation is context. A cost policy can turn that context into a deterministic threshold, but the estimate and the policy decision are still separate artifacts.

> This run estimates only a $0.30 monthly increase because the safe live configuration plans an ECS cluster and CloudWatch alarm while apply-sensitive runtime resources remain disabled. It proves the cost-estimation workflow, not the full production cost of the modeled payments platform.

Keep the risky fixture as the policy-review example. Do not substitute an invented production-scale cost estimate or imply that disabled resources were priced in the live run.

Do not use the legacy global cost-policy failure as the cost teaching moment. It runs in an agent environment without cost-estimation data and fails closed on a null input. Use the native cost estimate shown in the run.

### 6. Show Deterministic Policy

Open the Sentinel policy results.

Use one clear failure as the main teaching moment, such as:

- internet-facing production load balancer
- missing required tags
- minimum production capacity

For this recording, use the missing `Owner` tag. It directly matches `require-prod-tags` and avoids conflating native cost estimation with policy input that is unavailable in the legacy agent-executed policy set.

Say:

> Sentinel is deterministic policy code maintained by the platform team. The AI reviewer has no influence on this evaluation.

Explain the enforcement level shown in the actual run. Avoid describing OPA as having Sentinel's three enforcement levels; use the enforcement terms displayed by the selected framework.

Sentinel `soft-mandatory` failures stop the run until an authorized user overrides them. In HCP Terraform, the user needs **Manage Policy Overrides** permission for the applicable scope. The run timeline records the override, reviewer, timestamp, and comment; eligible audit-trail events also record the actor. For Sentinel policy checks in the platform execution environment used here, a `hard-mandatory` failure cannot be overridden and blocks the run. Sentinel policy evaluations use different override behavior: soft- and hard-mandatory levels are converted to `mandatory`, which authorized users may override when the policy set permits it.

In the fresh recording run, an authorized reviewer may override `require-prod-tags` only to demonstrate the approval and audit boundary. That does not delete or convert the failed decision into a pass. Supply a validation-only comment, continue to the confirmation boundary, and discard before apply.

### 7. Show The Optional External Gate

Only include this beat if a real run task is configured.

Show:

- lifecycle stage, such as post-plan
- advisory or mandatory enforcement
- external service result
- link or message returned to the run

Say:

> A run task is an integration point. HCP Terraform invokes an external service at a defined run stage and uses the task's result and enforcement level to decide whether the run can continue.

Do not call a run task a Sentinel policy and do not imply that Sentinel enforces every run-task response.

For a post-plan task, the initial POST includes run and workspace metadata, the lifecycle stage, an access token, a callback URL, and a `plan_json_api_url`. The external service retrieves the plan when needed and reports `running`, `passed`, or `failed` back to HCP Terraform with an optional message and detailed outcomes.

### 8. Stop At The Approval Boundary

End on the blocked or awaiting-confirmation run.

For the fresh recording run, override only the intentionally failed workspace-scoped `require-prod-tags` policy, include a clear validation-only comment, and continue only to the confirmation boundary. Never confirm apply.

Say:

> No autonomous apply is not a missing feature in this workflow. It is the deliberate accountability boundary. The system has authenticated the run, evaluated the change, exposed the cost, and preserved a decision for an authorized human.

## Screen Order

1. Completed safe run or run overview
2. Sanitized dynamic credential configuration
3. Risky Terraform diff
4. New standard plan with auto-apply disabled
5. Cost estimate
6. Sentinel policy results
7. Optional run-task result
8. Apply or policy-override boundary
9. Audit trail / run summary

## Expected Outcomes

The recording succeeds if viewers see:

- no static AWS credential values
- temporary run identity explained accurately
- a real Terraform plan
- a visible cost estimate or cost-policy result
- a deterministic policy result from the workspace-scoped policy set
- an attributed override and comment for the workspace-scoped soft-mandatory policy
- no apply
- a clear audit trail in HCP Terraform

## Common Mistakes

- Presenting policy as code or run tasks as currently supported Stack features.
- Claiming Stacks produce a single unified policy input for the whole component graph.
- Using `import "tfstack"` as if it were a documented Sentinel import.
- Saying Sentinel and OPA have identical enforcement-level names.
- Saying OPA enforcement is configured only in the HCP Terraform UI. VCS-backed OPA policies declare `advisory` or `mandatory` in `policies.hcl` or `policies.json`; the Rego logic returns the policy decision.
- Saying HCP Terraform sends the entire plan JSON directly in the initial run-task webhook.
- Treating a run task as another name for a Sentinel policy.
- Implying Sentinel automatically consumes and enforces every run-task result.
- Showing static cloud credentials to make the demo easier.
- Applying the intentionally risky plan.
- Letting the AI reviewer appear to influence deterministic policy evaluation.

## Recovery Path

If dynamic credentials fail:

- stop the live run
- show the sanitized OIDC flow diagram
- use a previously captured run
- do not fall back to visible static AWS keys

If cost estimation is empty:

- explain that not every resource is estimable
- show the previously captured native cost estimate
- do not invent a dollar amount

If the policy set is missing:

- use local Sentinel formatting and the existing captured HCP Terraform workspace-policy result
- do not attach or rewrite policies while recording

If no real run task is configured:

- omit that screen
- explain the integration point with the public lifecycle diagram
- keep Cloudability as a future validated integration demo

## Product Corrections For Episode 2

Before recording Steve's lightboard, review these draft claims:

- Stack-level policy sets and policy evaluation are not listed as supported in current public feature documentation.
- Run tasks are documented for workspace runs and are not listed as supported for Stacks.
- The draft's unified Stack plan JSON and `tfstack` Sentinel import should be removed unless Product provides current public documentation.
- Deferred values should not be described as eliminating unknown values from all policy evaluation.
- Sentinel and OPA should not be described as sharing identical enforcement levels.
- Run tasks return their own enforced result; do not say Sentinel necessarily consumes the result and blocks the run.
- Native HCP Terraform cost estimation and third-party FinOps run tasks are different implementation paths.

## Closing

> Governance does not have to mean one giant approval queue. HCP Terraform lets platform teams separate identity, deterministic policy, cost signals, external integrations, and human approval so each control can be automated at the right boundary and audited in the same run lifecycle.

## Public Sources To Recheck Before Recording

- HCP Terraform feature comparison for workspaces and Stacks
- HCP Terraform dynamic provider credentials
- HCP Terraform policy enforcement and policy-set scope
- HCP Terraform run-task lifecycle and integration payload
- HCP Terraform cost estimation
