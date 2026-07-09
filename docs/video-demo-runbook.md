# Video Demo Runbook

Working title:

> AI Agents Should Review Terraform Plans, Not Apply Them

## Demo Goal

Show a Terraform-native AI workflow that helps practitioners review infrastructure risk without giving an agent permission to apply changes.

The demo should make four ideas obvious:

1. Terraform produces the plan.
2. The assistant reviews and explains the plan.
3. Policy signals identify unsafe changes.
4. Authorization and human approval decide who can inspect or act.

## Setup Checks

From the repo root:

```bash
npm run check
npm run terraform:review
npm run terraform:report
npm run terraform:review -- data/terraform-plan.app-platform.json
npm run terraform:report -- data/terraform-plan.app-platform.json outputs/app-platform-plan-review-report.md
```

Optional Sentinel check:

```bash
sh scripts/use-local-sentinel.sh
PATH="/Users/jacobplicque/Documents/Codex/bin:$PATH" sentinel fmt -check policies/sentinel/*.sentinel
```

Optional `tfctl` check:

```bash
tfctl --version
tfctl auth status
tfctl harness context
```

If auth is inactive, keep `tfctl` as a talk-track item and use the local plan files for the live demo.

Optional SpiceDB check:

```bash
docker compose up -d spicedb
npm run authz:validate
npm run authz:load
npm run tool:call -- alice terraform.review_plan --provider=spicedb
npm run tool:call -- bob terraform.review_plan --provider=spicedb
```

## Demo Flow

### 1. Open With The Practitioner Problem

Say:

> Terraform plans are the right control point, but large plans are hard to review by eye. The question is not whether an AI agent can apply Terraform. The question is whether it can help humans understand risk before anything applies.

Show:

```bash
npm run terraform:review
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
npm run terraform:review -- data/terraform-plan.app-platform.json
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

> The CLI output is useful for automation, but practitioners need something they can attach to a PR, run review, or incident timeline.

Run:

```bash
npm run terraform:report -- data/terraform-plan.app-platform.json outputs/app-platform-plan-review-report.md
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

### 4. Explain Sentinel Versus SpiceDB

Say:

> There are two different questions here. SpiceDB answers who can inspect this plan or call this capability. Sentinel-style policy answers whether the Terraform change is acceptable.

Show:

```text
policies/sentinel
```

Optional command:

```bash
PATH="/Users/jacobplicque/Documents/Codex/bin:$PATH" sentinel fmt -check policies/sentinel/*.sentinel
```

Expected point:

- Policy examples correspond to the report findings.
- Sentinel is policy evaluation.
- SpiceDB/AuthZed is capability authorization.

### 5. Show Authorization Before Tool Use

If SpiceDB is running:

```bash
npm run tool:call -- alice terraform.review_plan --provider=spicedb
npm run tool:call -- bob terraform.review_plan --provider=spicedb
```

Expected point:

- Alice can call the plan review tool.
- Bob cannot call the production plan review tool.

If SpiceDB is not running:

```bash
npm run tool:call -- alice terraform.review_plan --provider=local
npm run tool:call -- bob terraform.review_plan --provider=local
```

Say:

> The local provider keeps the demo runnable. The SpiceDB path shows the production-shaped authorization boundary.

### 6. Show The Agent Boundary

Run:

```bash
npm run agent:run -- alice "Should we apply the Terraform change?" --provider=local
```

Expected point:

- The agent retrieves context.
- The agent calls authorized tools.
- The agent reviews Terraform risk.
- The proposal requires human approval.
- `mutationExecuted` remains `false`.

Say:

> This is the line I care about: the agent can explain, recommend, and propose. It does not apply.

## Optional Stacks Bridge

Show:

```text
terraform/workspace-to-stacks
docs/hashibank-stacks-companion.md
```

Say:

> The next version of this story is not just one plan. It is understanding component relationships: VPC to EKS to app, workspace sprawl to Stack deployments, and policy/approval at the platform boundary.

Keep this short in the first video. It is a bridge to the next deep dive, not the main demo.

## Optional HCP Terraform / tfctl Bridge

Show:

```text
docs/tfctl-hcp-terraform-bridge.md
```

Say:

> The local demo uses sample Terraform plan JSON so the workflow is easy to inspect. In production, HCP Terraform run data, policy checks, workspace variables, and Stack deployment context can become the source of truth. `tfctl` is the operator CLI bridge into that world.

If authenticated:

```bash
tfctl run status WORKSPACE_NAME
tfctl api /workspaces/{workspace}/runs -p workspace=WORKSPACE_NAME --jq '.data[] | {id, status: .attributes.status}'
```

Keep this optional in the first video. It is a bridge to the HCP Terraform control-plane deep dive.

## Fallbacks

If Docker or SpiceDB is not running:

- Use `--provider=local`.
- Explain that the authorization model is the same shape but backed by local fixtures.

If Sentinel is not on PATH:

- Use the policy files as readable examples.
- Show `docs/sentinel-local-setup.md`.
- Keep the runnable demo on `npm run terraform:review` and `npm run terraform:report`.

If Terraform Stacks commands fail:

- Explain that Stacks CLI commands require HCP Terraform discovery.
- Show the files and migration map.
- Keep the first video focused on plan review.

## Closing

Say:

> The goal is not to hand production to an agent. The goal is to make the agent a better reviewer inside the same governance model the platform already trusts.
