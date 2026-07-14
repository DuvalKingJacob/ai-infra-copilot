# Detecting And Remediating Drift In HCP Terraform

This is a practitioner companion walkthrough for the Terraform Enterprise video series.

The lightboard episode explains why drift matters. This walkthrough shows how a practitioner should detect, inspect, classify, and respond to drift without turning remediation into an uncontrolled apply.

Scope note:

> This walkthrough is workspace-based. It should not imply that Drift Detection works with Terraform Stacks. Stacks and Drift Detection are adjacent Infrastructure Lifecycle Management topics, but this demo uses a normal HCP Terraform or Terraform Enterprise workspace as the drift surface.

## Format

Recording runbook, not a finished script.

Target length:

```text
8-12 minutes
```

Companion role:

```text
Steve's lightboard: why drift matters
Jacob's walkthrough: how practitioners should investigate and remediate drift
```

## Learning Objectives

By the end, the viewer should understand:

- what infrastructure drift is and why it creates operational risk
- why drift detection is a review workflow, not just a notification
- how to inspect drift from HCP Terraform or Terraform Enterprise context
- how to separate harmless drift from risky production drift
- when to remediate with a Terraform run versus investigate, import, or escalate
- how this connects to future AI-assisted drift triage without letting an agent apply changes directly

## Prerequisites

Required for the safe/local walkthrough:

- Terraform installed
- this repository
- generated plan review reports from the fixture path

Required for a live HCP Terraform/TFE walkthrough:

- HCP Terraform or Terraform Enterprise workspace connected to this repository
- working directory configured to a Terraform root such as `terraform/app-platform`
- valid provider credentials or dynamic provider credentials
- auto-apply disabled
- permission to trigger speculative or normal plans

Optional:

- `tfctl` authenticated for read-only run/workspace inspection
- Sentinel policies or local Sentinel-style policy examples
- a non-production sandbox account for any live cloud drift demonstration

Do not make the first drift walkthrough depend on breaking real infrastructure. If live drift is not ready, use the report and HCP/TFE run context to teach the workflow.

Do not use the Stacks scenario for this walkthrough. Use a standard workspace so the demo matches the product surface being discussed.

## Demo Environment

Primary local path:

```text
terraform/app-platform
```

Useful commands:

```bash
make validate
make terraform-live-review
make terraform-live-risky-review
make report-app
```

Relevant outputs:

```text
outputs/live-app-platform-plan-review-report.md
outputs/live-risky-app-platform-plan-review-report.md
outputs/app-platform-plan-review-report.md
```

Optional HCP Terraform workspace:

```text
ai-infra-copilot
```

Optional read-only HCP context path:

```bash
TFCTL_WORKSPACE=ai-infra-copilot make agent-tfctl
TFCTL_WORKSPACE=ai-infra-copilot make tool-check-tfctl
```

## Mental Model

Drift means the real infrastructure no longer matches the declared Terraform configuration or the last expected state.

For practitioners, the important question is not only:

```text
Did drift happen?
```

The better operating questions are:

```text
What changed?
Who owns it?
What is the blast radius?
Is this safe to reconcile?
Should we apply, import, ignore, or escalate?
```

## Architecture

```text
Cloud resources
      |
      v
Terraform refresh / HCP Terraform drift detection
      |
      v
Plan or drift signal
      |
      v
Policy, ownership, run history, and workspace context
      |
      v
Human review
      |
      v
Approved Terraform remediation path
```

AI can help classify and explain the signal later, but Terraform remains the execution and audit control point.

## Step-By-Step Recording Plan

### 1. Start With The Operational Problem

Show:

```text
terraform/app-platform
```

Talk track:

> Drift usually starts with something human and reasonable: an emergency console change, a security team hotfix, a manual scaling adjustment, or a cloud-side default changing underneath you. The problem is that Terraform no longer has a clean shared understanding of reality.

Point out:

- this is not a toy problem
- drift can be harmless or dangerous
- the workflow should help humans prioritize

### 2. Show The Terraform-Controlled Baseline

Command:

```bash
terraform -chdir=terraform/app-platform fmt -check
terraform -chdir=terraform/app-platform init -backend=false
terraform -chdir=terraform/app-platform validate
```

Expected output:

```text
Terraform formatting check passes.
Terraform initializes without configuring a remote backend.
Success! The configuration is valid.
```

If provider downloads or network access fail:

```text
Use the fixture path and explain that the workflow is the important part, not local provider installation.
```

### 3. Show A Safe Plan Review

Command:

```bash
make report-app
open outputs/app-platform-plan-review-report.md
```

Expected output:

```text
Recommendation: allow_plan_with_review
No high-risk findings were detected.
The report states that no Terraform apply was run.
```

Talk track:

> A clean plan review is useful because it creates the comparison point. Before we talk about remediation, we need to know what normal review looks like.

### 4. Show A Risky Change As A Stand-In For Drift Review

Command:

```bash
make terraform-live-risky-review
open outputs/live-risky-app-platform-plan-review-report.md
```

Expected output:

```text
Recommendation: block_apply_pending_review
Findings may include internet-facing load balancer, low service capacity, missing tags, or other production-risk signals.
Approval required: yes.
```

If live AWS credentials are unavailable:

```bash
make report-app
open outputs/app-platform-plan-review-report.md
```

Then explain the intended live variation:

```text
In a live drift demo, the triggering signal would come from refresh/drift detection rather than a fixture or planned risky input.
```

Talk track:

> Drift review and plan review have the same operating shape: inspect the difference, classify the risk, decide the remediation path, and keep execution inside Terraform.

### 5. Show HCP Terraform / TFE As The Control Plane

Screen order:

1. HCP Terraform workspace overview.
2. Working directory and VCS connection.
3. Latest run or errored run.
4. Variables / credentials area, without exposing values.
5. Plan status, policy checks, or approval area if available.

Optional command:

```bash
tfctl run status ai-infra-copilot
```

Expected output:

```text
Run succeeded, plan errored, or no current run.
```

Any of those results are usable:

- succeeded: show healthy run context
- errored: show that HCP Terraform caught the workspace or credential problem before any apply
- no current run: show that the workspace exists but needs a run signal

Talk track:

> The important point is that the assistant is not becoming the control plane. HCP Terraform or TFE owns the run, variables, policy checks, approvals, state, and audit history.

### 6. Classify Drift Response Options

Show a simple table on screen or in notes:

| Drift Type | Example | Recommended Response |
| --- | --- | --- |
| Cosmetic | tag changed manually | review, decide whether to reconcile or update code |
| Configuration | instance size changed | investigate owner intent, plan remediation |
| Security | public ingress added | escalate and block auto-remediation |
| Unmanaged resource | resource created outside Terraform | consider import or new module ownership |
| Emergency change | manual production fix | preserve incident context before reverting |

Talk track:

> Remediation is not always "run apply." Sometimes the correct answer is import. Sometimes it is update the Terraform code. Sometimes it is leave the emergency change in place until the incident is understood.

### 7. Bridge To AI-Assisted Drift Triage

Show:

```text
docs/ai-repo-backlog.md
```

Talk track:

> At small scale, a human can inspect drift one workspace at a time. At large scale, the value of an assistant is classification and prioritization: which drift is cosmetic, which is risky, which team owns it, and which remediation path should be reviewed first.

Emphasize:

- AI can collect context
- AI can classify risk
- AI can recommend next steps
- humans approve
- Terraform executes

### 8. Close With The Practitioner Takeaway

Closing message:

> Drift detection matters because Terraform is only useful as a control plane if teams trust the relationship between configuration, state, and real infrastructure. The mature workflow is not "detect drift and auto-fix everything." The mature workflow is detect, classify, review, remediate through Terraform, and preserve an audit trail.

## Exact Commands

Local validation:

```bash
make validate
terraform -chdir=terraform/app-platform fmt -check
terraform -chdir=terraform/app-platform init -backend=false
terraform -chdir=terraform/app-platform validate
```

Fixture report:

```bash
make report-app
open outputs/app-platform-plan-review-report.md
```

Live safe report:

```bash
make terraform-live-review
open outputs/live-app-platform-plan-review-report.md
```

Live risky report:

```bash
make terraform-live-risky-review
open outputs/live-risky-app-platform-plan-review-report.md
```

HCP Terraform context:

```bash
tfctl auth status
tfctl run status ai-infra-copilot
TFCTL_WORKSPACE=ai-infra-copilot make agent-tfctl
```

## Expected Outputs

| Command | Expected Result |
| --- | --- |
| `make validate` | repo validation passes |
| `terraform ... validate` | app-platform configuration is valid |
| `make report-app` | fixture report is generated |
| `make terraform-live-review` | safe live plan report is generated if credentials are available |
| `make terraform-live-risky-review` | risky live plan report blocks apply pending review |
| `tfctl run status ai-infra-copilot` | current HCP Terraform run status, errored run, or no current run |
| `make agent-tfctl` | agent reads authorized HCP context and stops before mutation |

## Common Mistakes

- Treating drift detection as automatic remediation.
- Reverting emergency changes without understanding why they happened.
- Ignoring ownership and environment context.
- Recording a live demo that depends on fragile cloud credentials.
- Letting the AI angle swallow the Terraform practitioner lesson.
- Showing sensitive variable values, account IDs, ARNs, or customer-specific resource names.

## Recovery / Fallback Path

If live HCP Terraform drift detection is not ready:

1. Use `make report-app`.
2. Show the HCP Terraform workspace as the intended control plane.
3. Explain the live blocker honestly: credentials, working directory, or no current run.
4. Use the risky plan report to demonstrate the review and approval pattern.

If AWS credentials fail:

```text
Do not troubleshoot credentials during recording.
Switch to the fixture report and keep the lesson on drift workflow.
```

If `tfctl` cannot resolve the workspace:

```bash
tfctl api /organizations/{organization}/workspaces -f 'search[name]=ai-infra' --jq '.data[] | {name: .attributes.name, id: .id}'
```

Then rerun with the exact workspace name.

## HCP Terraform / TFE Tie-Back

This walkthrough should reinforce adoption of HCP Terraform and Terraform Enterprise by showing that drift is easier to govern when teams have:

- centralized workspace context
- remote state and run history
- VCS-connected configuration
- controlled variables and provider credentials
- policy checks
- approval workflows
- audit history
- a clear place for future AI-assisted review

The product story is:

> Drift detection tells teams where declared infrastructure and real infrastructure have diverged. HCP Terraform and Terraform Enterprise provide the workflow to review, govern, and remediate that divergence. AI can help prioritize and explain, but Terraform remains the control point.

## Future AI Extension

After the basic drift walkthrough exists, a later companion demo can show AI-assisted drift triage at estate scale:

```text
hundreds of drift events -> classification -> priority queue -> recommended remediation path -> human approval -> Terraform run
```

That should be a separate video or demo. Keep this walkthrough focused on the practitioner drift workflow first.
