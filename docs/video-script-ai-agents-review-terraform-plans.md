# Video Script: AI Agents Should Review Terraform Plans, Not Apply Them

## Working Title

AI Agents Should Review Terraform Plans, Not Apply Them

## Target Length

10-12 minutes

## Audience

- Terraform practitioners
- Platform engineers
- SREs
- DevOps engineers
- Infrastructure architects evaluating AI-assisted workflows

## Core Thesis

AI can help practitioners understand Terraform risk, but production apply should stay behind policy, authorization, approval, and audit.

## Opening Hook

Say:

> AI can write Terraform now. That is not the interesting part.
>
> The interesting question is what happens when an AI assistant can inspect a Terraform plan, read infrastructure context, and call operational tools.
>
> Do we let it apply?
>
> I do not think that is the right first pattern. The safer and more useful pattern is: let the assistant review the plan, explain the risk, surface policy signals, and stop at human approval.

Visual:

```text
Terraform plan
  -> AI review
  -> policy signal
  -> authorization boundary
  -> human approval
  -> controlled apply
```

Transition:

> So in this demo, the agent does not get root access to production. It gets a job that platform teams already do every day: review the plan before anything changes.

## 0:45 - 2:00 | The Practitioner Problem

Say:

> Terraform plans are the right control point. They show what is going to change before it changes.
>
> But in real environments, plans can be noisy. You might have hundreds of lines of output, multiple resources, hidden blast radius, and a reviewer trying to answer a very human question: should we approve this?
>
> This is where I think AI can be useful. Not as an operator with unchecked authority, but as a reviewer that helps humans see risk faster.

Show the repo title and README:

```text
AI-Assisted Terraform Operations
```

Say:

> This project explores a conservative workflow. Terraform produces the plan. The assistant reviews it. Policy findings identify unsafe changes. Authorization decides who can see the context. Human approval controls whether anything proceeds.

## 2:00 - 3:30 | Small Plan Review Example

Run:

```bash
npm run terraform:review
```

Say:

> The first example is intentionally small: production networking, IAM, and monitoring.
>
> The reviewer catches three things a Terraform practitioner would immediately care about.

Call out expected findings:

- Public ingress via `0.0.0.0/0`.
- Wildcard IAM permissions.
- Monitoring alarm deletion.
- Recommendation: `block_apply_pending_review`.

Say:

> The important thing is not that this is magic. It is not. These are deterministic checks over Terraform plan JSON.
>
> The useful part is the product shape: the assistant turns plan data into an explainable review artifact and a recommendation.

## 3:30 - 5:30 | SRE-Style App Platform Review

Say:

> The smaller example proves the pattern, but it does not feel like a full SRE review. So here is a more realistic app-platform scenario.
>
> This plan touches a load balancer, an ECS service, a database, monitoring, and tags.

Run:

```bash
npm run terraform:review -- data/terraform-plan.app-platform.json
```

Call out expected findings:

- Internal load balancer becomes internet-facing.
- Production database is replaced.
- Database deletion protection is disabled.
- ECS desired count drops from `6` to `1`.
- Latency alarm is deleted.
- Required ownership and environment tags are missing.

Say:

> That is the kind of review where AI can help. Not because the model is smarter than the platform team, but because it can summarize risk across different operational dimensions: network exposure, data-plane risk, availability, observability, and governance.

## 5:30 - 6:45 | Generate A Review Artifact

Say:

> CLI output is useful for automation. But humans need something they can attach to a pull request, paste into an incident timeline, or use in a run review.

Run:

```bash
npm run terraform:report -- data/terraform-plan.app-platform.json outputs/app-platform-plan-review-report.md
```

Open:

```text
outputs/app-platform-plan-review-report.md
```

Say:

> The report gives us a summary, resource counts, findings mapped to policy names, a recommendation, and a blast-radius section written in operational language.
>
> This is the shape I want from an AI-assisted Terraform workflow: not a hidden decision, but a review artifact.

Point to:

- Recommendation: `block_apply_pending_review`.
- Risk findings table.
- Blast radius.
- "What The Agent Did Not Do".

Say:

> This section matters. The agent did not run `terraform apply`. It did not mutate infrastructure. It produced an explainable artifact for a human-controlled workflow.

## 6:45 - 8:00 | Policy Is Not The Same As Authorization

Say:

> Now there is a subtle distinction here that matters a lot for AI systems.
>
> There are two different questions:
>
> One: is this actor allowed to inspect this plan or call this tool?
>
> Two: is this Terraform change acceptable under policy?

Show:

```text
policies/sentinel
spicedb/schema.zed
```

Say:

> Sentinel-style policy answers the second question: no public load balancers, no production database replacement, no dangerous capacity reduction, no missing required tags.
>
> SpiceDB/AuthZed answers the first question: can Alice call the production plan review tool? Can Bob? Can this actor see this context?

Optional command:

```bash
PATH="/Users/jacobplicque/Documents/Codex/bin:$PATH" sentinel fmt -check policies/sentinel/*.sentinel
```

Say:

> That distinction becomes more important once AI enters the workflow. You do not only need policy on the infrastructure. You need authorization around the assistant's access to context and tools.

## 8:00 - 9:15 | Authorization Before Tool Use

If SpiceDB is running, run:

```bash
npm run tool:call -- alice terraform.review_plan --provider=spicedb
npm run tool:call -- bob terraform.review_plan --provider=spicedb
```

If SpiceDB is not running, run:

```bash
npm run tool:call -- alice terraform.review_plan --provider=local
npm run tool:call -- bob terraform.review_plan --provider=local
```

Say:

> The tool call is deliberately boring. That is the point.
>
> Before the assistant gets plan review output, we check whether the actor is allowed to call that capability.
>
> Alice can inspect production Terraform context. Bob cannot. The model never receives the denied tool output.

Connect to MCP:

> This is also how I think about MCP. MCP makes capabilities available to agents. Authorization decides which capabilities are safe for a particular actor, resource, and workflow.

## 9:15 - 10:30 | Agent Boundary

Run:

```bash
npm run agent:run -- alice "Should we apply the Terraform change?" --provider=local
```

Say:

> This command ties the pieces together. The agent classifies the request, retrieves context, checks permissions, calls authorized tools, reviews Terraform risk, and proposes next steps.
>
> But look at the boundary: the proposal requires human approval, and `mutationExecuted` is false.

Point to:

```text
proposal.status = requires_human_approval
mutationExecuted = false
```

Say:

> That is the design choice. The agent can answer, review, and propose. It does not apply.

## 10:30 - 11:30 | Bridge To HCP Terraform, Stacks, And tfctl

Say:

> This demo uses local plan JSON so the workflow is easy to inspect. In production, the source of truth would be HCP Terraform: workspaces, runs, policy checks, variables, state versions, and Stack deployments.
>
> That is where tools like `tfctl`, the Terraform MCP Server, and HCP Terraform become the real control-plane bridge.

Show:

```text
docs/tfctl-hcp-terraform-bridge.md
terraform/workspace-to-stacks
docs/hashibank-stacks-companion.md
```

Say:

> The next version of this workflow is not just reviewing one local plan. It is understanding relationships: VPC to EKS to application, workspace sprawl to Stack components, and policy or approval at the deployment boundary.

Keep this short:

> That is the next deep dive. For this video, the core pattern is plan review first, action later.

## 11:30 - Close

Say:

> The goal is not to hand production to an agent.
>
> The goal is to make the agent a better reviewer inside the same governance model the platform already trusts.
>
> Terraform plans remain the control point. Sentinel-style policy evaluates the change. SpiceDB/AuthZed controls access to context and tools. HCP Terraform remains the system of record for runs, approvals, and audit.
>
> That is the pattern I want from AI-assisted infrastructure operations: helpful, explainable, authorized, and still human-controlled where it matters.

## Demo Commands

```bash
npm run check
npm run terraform:review
npm run terraform:report
npm run terraform:review -- data/terraform-plan.app-platform.json
npm run terraform:report -- data/terraform-plan.app-platform.json outputs/app-platform-plan-review-report.md
PATH="/Users/jacobplicque/Documents/Codex/bin:$PATH" sentinel fmt -check policies/sentinel/*.sentinel
npm run tool:call -- alice terraform.review_plan --provider=local
npm run tool:call -- bob terraform.review_plan --provider=local
npm run agent:run -- alice "Should we apply the Terraform change?" --provider=local
```

## Optional Live HCP Terraform Commands

Only use these if `tfctl auth status` is active:

```bash
tfctl auth status
tfctl run status WORKSPACE_NAME
tfctl api /workspaces/{workspace}/runs -p workspace=WORKSPACE_NAME --jq '.data[] | {id, status: .attributes.status}'
tfctl api /runs/RUN_ID/policy-checks --jq '.data[] | {id: .id, status: .attributes.status, enforced: .attributes.enforcement-level}'
```

## Notes For Recording

- Keep the first video focused on Terraform plan review.
- Mention MCP, RAG, Stacks, and tfctl as supporting architecture, not the main subject.
- Avoid implying the assistant is making final approval decisions.
- Avoid live HCP Terraform dependency unless auth and workspace names are confirmed before recording.
- Use `app-platform` as the main demo because it feels like real SRE/platform work.

