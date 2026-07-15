# HCP Terraform Run Control

This runbook explains how this project should use HCP Terraform or Terraform Enterprise as the control plane for AI-assisted Terraform workflows.

The short version:

> Use the UI to configure and troubleshoot. Use VCS, CI, or `tfctl` to trigger and inspect repeatable workflows. Keep policy checks, approvals, overrides, state, and audit in HCP Terraform or Terraform Enterprise.

## Why This Matters

An AI assistant should not become a parallel deployment system.

The production-shaped workflow should look like this:

```text
GitHub or CI change
  -> HCP Terraform run
  -> plan
  -> policy checks
  -> optional run task / AI review artifact
  -> human approval or policy override
  -> Terraform-controlled apply
  -> state and audit history
```

The workflow can retrieve authorized context for the assistant to summarize, classify risk, explain policy signals, and propose next steps. The assistant should not directly apply Terraform, override policy, or destroy infrastructure outside the Terraform run lifecycle.

## When To Use Each Control Path

| Control Path | Use It For | Avoid Using It For |
| --- | --- | --- |
| HCP Terraform UI | initial setup, screenshots, workspace settings, debugging failed runs, approving/overriding with a human | repeatable automation demos |
| VCS-triggered run | normal practitioner workflow from commit to plan | ad hoc investigation without a code change |
| CI-triggered run | controlled team workflow, checks before run creation, repeatable release paths | bypassing HCP Terraform policy or approvals |
| `tfctl` | read-only run/workspace inspection, scripted demos, controlled operator workflows | hidden mutation, policy override, or destroy from an agent |
| AI agent | summarize, classify, explain, and recommend | apply, destroy, policy override, credential access |

## Recommended Demo Flow

Use the UI once to prove the workspace is configured:

```text
workspace exists
VCS repo connected
working directory set
AWS/provider credentials configured
Sentinel policy set attached
auto-apply disabled
```

Then shift the demo to a repeatable workflow:

```text
commit or CI trigger
  -> HCP Terraform run
  -> plan and policy checks
  -> tfctl reads run context
  -> agent summarizes or triages
  -> human decides in HCP Terraform
```

For this repo, the workspace used during validation was:

```text
ai-infra-copilot
```

The working directory should point at:

```text
terraform/app-platform
```

## Safe `tfctl` Inspection

Check authentication:

```bash
tfctl auth status
```

Check the latest run:

```bash
tfctl run status ai-infra-copilot
```

List recent runs:

```bash
tfctl api /workspaces/{workspace}/runs -p workspace=ai-infra-copilot --jq '.data[] | {id, status: .attributes.status, created_at: .attributes.["created-at"]}'
```

Inspect workspace variable metadata without exposing values:

```bash
tfctl api /workspaces/{workspace}/vars -p workspace=ai-infra-copilot --jq '.data[] | {key: .attributes.key, category: .attributes.category, sensitive: .attributes.sensitive}'
```

Run the agent with read-only HCP Terraform context:

```bash
TFCTL_WORKSPACE=ai-infra-copilot make agent-tfctl
```

This path reads context. It does not start, approve, apply, override, or destroy runs.

## Applying And Destroying

For this demo, applies and destroys should remain human-controlled HCP Terraform actions.

The live app-platform configuration is intentionally guarded:

```text
create_runtime_resources = false
```

With the safe default, the workspace can prove run lifecycle, policy checks, outputs, state, and audit without creating environment-specific resources such as load balancers, ECS services, or RDS instances.

Only set:

```text
create_runtime_resources = true
```

when the workspace has real subnet IDs, a real ECS task definition, database prerequisites, and explicit approval to create those resources.

## Policy Override Boundary

Policy override is a human governance action.

The assistant may explain:

- which policy failed
- why the policy failed
- what risk the policy is trying to control
- what options the reviewer has

The assistant should not perform the override.

Good demo phrasing:

> The assistant can explain the failed policy and recommend next steps, but the policy override stays in HCP Terraform as a human decision with audit history.

## CI Story

CI should prove the non-cloud path:

```bash
make ci
```

That validates:

- local Terraform formatting
- fixture-based plan review
- Markdown report generation
- drift triage report generation
- local authorization checks
- deterministic agent behavior
- Sentinel policy formatting

CI should not run live cloud plans or applies by default.

If a future CI workflow triggers HCP Terraform runs, it should:

1. authenticate with a scoped token
2. create or request a run in HCP Terraform
3. wait for plan and policy status
4. publish a review artifact
5. stop before apply unless a human approval path exists

## Thursday Demo Talk Track

Use this framing:

> The UI helped validate the workspace, credentials, and policy set. The production-shaped workflow is not "click around and let an agent apply." The workflow is commit or CI into HCP Terraform, policy checks and approvals in HCP Terraform, `tfctl` for controlled context inspection, and the agent as a reviewer or triage assistant.

That keeps the product story aligned:

```text
Terraform remains the control plane.
HCP Terraform/TFE remains the system of record.
AI improves review quality and triage speed.
Humans keep approval and override authority.
```
