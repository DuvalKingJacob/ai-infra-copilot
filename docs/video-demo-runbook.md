# Video Demo Runbook

Working title:

> AI Should Review Terraform Plans, Not Apply Them

Related production artifacts:

- `docs/video-architecture-diagram.md`

The polished script and teleprompter copy live outside this repo as Word production documents. This repo keeps the technical demo runbook, commands, and source-of-truth implementation.

## Demo Goal

Show how AI can improve Terraform plan review without bypassing the governance model teams already use in HCP Terraform and Terraform Enterprise.

The demo should make five ideas obvious:

1. HCP Terraform/TFE remains the production control plane for runs, plans, policy checks, approvals, state, variables, and audit.
2. The local repo is a simplified reference implementation of that production workflow.
3. The assistant reviews and explains Terraform risk before approval.
4. Policy, authorization, and human approval remain separate control points.
5. `tfctl` and the Terraform MCP Server are examples of controlled interfaces into Terraform workflows; they do not remove the need for policy, approval, and audit.

## Setup Checks

From the repo root:

```bash
make validate
make review
make report
make review-app
make report-app
```

Optional Sentinel check:

```bash
sh scripts/use-local-sentinel.sh
make sentinel-check
```

Optional `tfctl` check:

```bash
tfctl --version
tfctl auth status
tfctl harness context
```

If auth is inactive, keep `tfctl` as a talk-track item and use the local plan files for the live demo.

Optional external authorization check:

```bash
docker compose up -d spicedb
make authz-load
make tool-check
```

## Demo Flow

### 1. Open With The Practitioner Problem

Say:

> Terraform plans are the right control point, but large plans are hard to review by eye. The question is not whether an AI agent can apply Terraform. The question is how AI should fit into the Terraform run workflow teams already trust.
>
> In production, that means HCP Terraform or Terraform Enterprise remains the system of record for runs, plans, policy checks, approvals, variables, state, and audit logs. This local demo is a small, inspectable version of that pattern.
>
> Put another way: AI can make the Terraform review loop easier to understand, but Terraform remains the infrastructure control point.

Show:

```bash
make review
```

Expected point:

- Public ingress is flagged.
- Wildcard IAM is flagged.
- Monitoring deletion is flagged.
- Recommendation is `block_apply_pending_review`.

### 2. Move To The SRE Scenario

Say:

> The small network example proves the pattern. Now here is a more realistic SRE review: app platform, load balancer, service capacity, database, monitoring, and tags.

Run:

```bash
make review-app
```

Expected point:

- Internal load balancer becomes internet-facing.
- Database replacement is detected.
- Database deletion protection is disabled.
- ECS desired count drops from `6` to `1`.
- Latency alarm is deleted.
- Required tags are missing.

### 3. Generate The Review Artifact

Say:

> The CLI output is useful for automation, but practitioners need something they can attach to a PR, run review, Slack approval, run task result, or incident timeline.

Run:

```bash
make report-app
```

Open:

```text
outputs/app-platform-plan-review-report.md
```

Expected point:

- Summary gives resource counts and recommendation.
- Findings map to policy names.
- Blast radius is written in operational language.
- The report explicitly says the agent did not apply.

HashiCorp adoption talk track:

> In HCP Terraform or TFE, this type of artifact could sit next to the run, policy checks, and approval workflow. The agent is improving review quality, not becoming a parallel deployment system.

### 4. Explain Policy Versus Authorization

Say:

> There are two different questions here. Sentinel or OPA answers whether the Terraform change is acceptable. Authorization answers who can retrieve run context, pass it to an AI workflow, or call an AI-accessible Terraform capability.

Show:

```text
policies/sentinel
```

Optional command:

```bash
make sentinel-check
```

Expected point:

- Policy examples correspond to the report findings.
- Sentinel or OPA is Terraform policy evaluation.
- HCP Terraform/TFE policy checks and approvals are the primary HashiCorp governance story.
- SpiceDB/AuthZed is one example authorization provider around AI tool and context access.

### 5. Show Authorization Before Tool Use

If SpiceDB is running:

```bash
make tool-check
```

Expected point:

- Alice can call the plan review tool.
- Bob cannot call the production plan review tool.

If SpiceDB is not running:

```bash
make tool-check-local
```

Say:

> The local provider keeps the demo runnable. The SpiceDB path is an optional example of a production-shaped authorization boundary around the AI interface.

### 6. Show The Agent Boundary

Run:

```bash
make agent
```

Expected point:

- The agent retrieves context.
- The agent calls authorized tools.
- The agent reviews Terraform risk.
- The proposal requires human approval.
- `mutationExecuted` remains `false`.

Say:

> This is the line I care about: the agent can explain, recommend, and propose. Terraform runs, policy checks, approvals, and audit remain the operational control points.

## Optional Stacks Bridge

Show:

```text
terraform/workspace-to-stacks
docs/hashibank-stacks-companion.md
```

Say:

> The next version of this story is not just one plan. It is understanding component relationships: VPC to EKS to app, workspace sprawl to Stack deployments, and policy or approval at the platform boundary.

Keep this short in the first video. It is a bridge to the next deep dive, not the main demo.

## Optional HCP Terraform / tfctl Bridge

Show:

```text
docs/tfctl-hcp-terraform-bridge.md
```

Say:

> The local demo uses sample Terraform plan JSON so the workflow is easy to inspect. In production, HCP Terraform or TFE run data, policy checks, workspace variables, state metadata, audit logs, and Stack deployment context become the source of truth. `tfctl` is one operator CLI bridge into that world.
>
> The Terraform MCP Server is another public interface pattern: it can expose Terraform Registry and HCP Terraform/TFE context to compatible assistants. That makes authorization and review boundaries more important, because context exposed to an assistant may become model-visible.

If authenticated:

```bash
tfctl run status WORKSPACE_NAME
tfctl api /workspaces/{workspace}/runs -p workspace=WORKSPACE_NAME --jq '.data[] | {id, status: .attributes.status}'
```

Keep this optional in the first video. It is a bridge to the HCP Terraform/TFE control-plane deep dive.

## Fallbacks

If Docker or SpiceDB is not running:

- Use `--provider=local`.
- Explain that the authorization model is the same shape but backed by local fixtures instead of an external provider.

If Sentinel is not on PATH:

- Use the policy files as readable examples.
- Show `docs/sentinel-local-setup.md`.
- Keep the runnable demo on `make review` and `make report`.

If Terraform Stacks commands fail:

- Explain that Stacks CLI commands require HCP Terraform discovery.
- Show the files and migration map.
- Keep the first video focused on plan review.

## Closing

Say:

> The goal is not to hand production to an agent. The goal is to make the agent a better reviewer inside the same Terraform governance model the platform already trusts.
