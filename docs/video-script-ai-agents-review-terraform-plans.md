# Video Script: AI Should Review Terraform Plans, Not Apply Them

## Working Title

AI Should Review Terraform Plans, Not Apply Them

Alternate HashiCorp-aligned title:

How AI Should Fit Into Terraform Runs

## Target Length

10-12 minutes

## Audience

- Terraform practitioners
- Platform engineers
- SREs
- DevOps engineers
- Infrastructure architects evaluating HCP Terraform or Terraform Enterprise

## Core Thesis

AI agents should improve Terraform plan review inside the governance model teams already use in HCP Terraform and Terraform Enterprise. The agent can summarize authorized context, explain compound operational risk, surface policy results, and propose next steps, but production apply should remain controlled by Terraform runs, policy checks, approvals, audit logs, and human operators.

## Opening Hook

Say:

> AI can write Terraform now. That is useful, but it is not the adoption story I care about most.
>
> The bigger question is: how should AI fit into a real Terraform run?
>
> If your team already depends on HCP Terraform or Terraform Enterprise for plans, policy checks, approvals, variables, state, and audit logs, you probably do not want an agent bypassing that control plane.
>
> The safer pattern is this: AI reviews the plan. HCP Terraform or Terraform Enterprise remains the system of record.

Visual:

```text
HCP Terraform / TFE run
  -> Terraform plan
  -> policy checks
  -> AI-assisted review
  -> human approval
  -> controlled apply
  -> audit trail
```

Transition:

> So this video is not about giving an agent production credentials and hoping for the best. It is about using AI to make the existing Terraform run workflow easier to understand, easier to review, and safer to approve.

## 0:45 - 2:00 | The Practitioner Problem

Say:

> Terraform plans are the right control point because they show what will change before it changes.
>
> But in real environments, plans are hard to review. A single run might touch networking, IAM, compute, databases, monitoring, tags, and downstream dependencies.
>
> HCP Terraform and Terraform Enterprise already give teams the governance foundation: remote runs, state, variables, policy checks, run tasks, approvals, notifications, audit logs, workspaces, and now Stacks for larger orchestration problems.
>
> AI should plug into that model. It should not replace it.

Show the repo title and README:

```text
AI-Assisted Terraform Operations
```

Say:

> This repo is a simplified reference implementation of that workflow. The demo runs locally so we can inspect every piece, but the production pattern maps directly back to HCP Terraform and Terraform Enterprise.

## 2:00 - 3:30 | Production Mental Model

Say:

> In production, I would expect the control plane to look like this.

Show:

```text
HCP Terraform / TFE
  - workspace or Stack context
  - run and plan output
  - variables and state metadata
  - Sentinel or OPA policy checks
  - run tasks and notifications
  - approval gates
  - audit logs

AI review service
  - reads authorized run context
  - summarizes plan risk
  - explains policy findings
  - proposes next steps
  - never applies directly

Authorization layer
  - controls who can ask the agent
  - controls which tools the agent may call
  - controls which run, workspace, or Stack context is visible
```

Say:

> That distinction matters. Terraform is still doing Terraform. HCP Terraform or TFE still owns the run lifecycle. The agent is using Terraform context to help a human make a better decision.

## 3:30 - 4:45 | Small Plan Review Example

Run:

```bash
make review
```

Say:

> The first local example is intentionally small: production networking, IAM, and monitoring.
>
> Think of this as the kind of signal an AI review step could add to an HCP Terraform run page, pull request, Slack notification, or run task integration.

Call out expected findings:

- Public ingress via `0.0.0.0/0`.
- Wildcard IAM permissions.
- Monitoring alarm deletion.
- Recommendation: `block_apply_pending_review`.

Say:

> The important thing is not that this is magic. It is not. These are deterministic checks over Terraform plan JSON.
>
> The useful product shape is that the assistant turns raw plan data into an explainable review artifact before approval.

## 4:45 - 6:30 | SRE-Style App Platform Review

Say:

> The smaller example proves the pattern, but it does not answer the most important skeptical question: why not just use Sentinel, Checkov, or another deterministic scanner?
>
> The answer is not that AI should replace those tools. It should not.
>
> The stronger case is compound operational risk. Here is a more realistic app-platform scenario.
>
> This plan touches a load balancer, an ECS service, a database, monitoring, and tags. This is the kind of change where practitioners need context, not just a green or red result.

Run:

```bash
make review-app
```

Call out the compound risk first:

- Production database is replaced.
- Database deletion protection is disabled.
- ECS desired count drops from `6` to `1`.
- Latency alarm is deleted.
- Required ownership and environment tags are missing.

Then mention the individual findings:

- Internal load balancer becomes internet-facing.

Say:

> This is where AI can help HCP Terraform and TFE adoption. Not by replacing policy. Not by replacing approval. By making the review experience better for the operator.
>
> Sentinel can deterministically fail specific rules. AI can help summarize the combined story for a human reviewer: this is not just one risky attribute; it is data durability risk, availability risk, observability risk, and ownership risk arriving in one plan.

## 6:30 - 7:30 | Generate A Review Artifact

Say:

> CLI output is useful for automation. But teams also need artifacts they can attach to a pull request, run review, incident timeline, or change record.

Run:

```bash
make report-app
```

Open:

```text
outputs/app-platform-plan-review-report.md
```

Say:

> The report gives us a summary, resource counts, findings mapped to policy names, a recommendation, and a blast-radius section written in operational language.
>
> In an HCP Terraform or TFE workflow, this could become a run task comment, a PR comment, a Slack approval summary, or a companion view next to the plan.

Point to:

- Recommendation: `block_apply_pending_review`.
- Risk findings table.
- Blast radius.
- "What The Agent Did Not Do".

Say:

> This section matters. The agent did not run `terraform apply`. It did not mutate infrastructure. It produced an explainable artifact for a human-controlled Terraform workflow.

## 7:30 - 8:45 | Policy Is Not The Same As Authorization

Say:

> Now there is a subtle distinction here that matters a lot once AI enters the platform.
>
> Policy answers: is this Terraform change acceptable?
>
> Authorization answers: is this actor allowed to inspect this run, retrieve this context, or call this tool?

Show:

```text
policies/sentinel
spicedb/schema.zed
```

Say:

> Sentinel or OPA belongs close to the Terraform run. That is where your platform team writes deterministic policy code for rules like no public load balancers, no production database replacement, no dangerous capacity reduction, and no missing required tags.
>
> The AI does not influence Sentinel evaluation. It can explain the policy result after HCP Terraform or Terraform Enterprise has already evaluated it.
>
> SpiceDB or AuthZed is a separate example of relationship-based authorization around AI tool access. It answers questions like: can Alice ask the agent to inspect this production run? Can Bob retrieve this workspace context? Can this agent call a Terraform tool for this environment?

Optional command:

```bash
make sentinel-check
```

Say:

> For the HashiCorp story, Sentinel, policy checks, run tasks, approvals, and audit logs are the primary governance model. Authorization around the agent is additive. It protects the AI interface so the model only sees and does what the actor is allowed to access.

## 8:45 - 9:45 | Authorization Before Tool Use

If SpiceDB is running, run:

```bash
make tool-check
```

If SpiceDB is not running, run:

```bash
make tool-check-local
```

Say:

> The tool call is deliberately boring. That is the point.
>
> Before the assistant receives plan review output, we check whether the actor is allowed to call that capability.
>
> Alice can request authorized production Terraform context. Bob cannot. The denied output never becomes model context.

Connect to MCP:

> This is also how I think about MCP. MCP can expose Terraform capabilities to agents. That might be the Terraform MCP Server, `tfctl`, a custom run-task integration, or an internal platform tool.
>
> But MCP does not remove the need for authorization. It makes the tool boundary explicit. Platform teams still need to decide which actor can call which tool against which workspace, Stack, run, or environment.

## 9:45 - 10:45 | Agent Boundary

Run:

```bash
make agent
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

> That is the design choice. The agent can answer, review, and propose. Terraform runs, policy checks, approvals, and audit remain the operational control points.

## 10:45 - 11:45 | Bridge To HCP Terraform, TFE, Stacks, And tfctl

Say:

> The demo uses local plan JSON so the workflow is easy to review. In production, I would expect HCP Terraform or Terraform Enterprise to provide the real source of truth: runs, plans, policy checks, variables, state versions, workspace metadata, audit logs, and Stack deployments.
>
> `tfctl` and the Terraform MCP Server are interesting because they can become bridges between an AI assistant and that Terraform control plane.

Show:

```text
docs/tfctl-hcp-terraform-bridge.md
terraform/workspace-to-stacks
docs/hashibank-stacks-companion.md
```

Say:

> The next version of this workflow is not just reviewing one local plan. It is understanding relationships: VPC to EKS to application, workspace sprawl to Stack components, policy checks at deployment boundaries, and approvals where the organization already expects them.

Keep this short:

> That is the next deep dive. For this video, the key adoption message is simple: AI should make Terraform runs easier to review without bypassing HCP Terraform or TFE governance.

## 11:45 - Close

Say:

> The goal is not to hand production to an agent.
>
> The goal is to make the agent a better reviewer inside the same Terraform governance model the platform already trusts.
>
> Terraform plans remain the control point. HCP Terraform and Terraform Enterprise remain the system of record for runs, policy checks, approvals, variables, state, and audit. Sentinel or OPA evaluates the change. Authorization controls which context and tools can be passed to the agent.
>
> That is the pattern I want from AI-assisted Terraform operations: helpful, explainable, policy-aware, authorized, and still human-controlled where it matters.

## Demo Commands

```bash
make validate
make review
make report
make review-app
make report-app
make sentinel-check
make tool-check-local
make agent
```

## Optional Live HCP Terraform Commands

Only use these if `tfctl auth status` is active and the workspace/run names are confirmed:

```bash
tfctl auth status
tfctl run status WORKSPACE_NAME
tfctl api /workspaces/{workspace}/runs -p workspace=WORKSPACE_NAME --jq '.data[] | {id, status: .attributes.status}'
tfctl api /runs/RUN_ID/policy-checks --jq '.data[] | {id: .id, status: .attributes.status, enforced: .attributes.enforcement-level}'
```

Use these as talk track if live auth is not ready:

- HCP Terraform/TFE runs are the production source of truth.
- Sentinel or OPA policy checks are the production policy layer.
- Run tasks can attach external review and security signals.
- Approvals and audit logs keep the final decision in the governed Terraform workflow.
- Workspace and Stack context make the agent more useful than a generic chatbot.

## Notes For Recording

- Keep the first video focused on how AI should fit into Terraform runs.
- Treat the local repo as a reference implementation, not the product being promoted.
- Make HCP Terraform/TFE the center of gravity.
- Mention MCP, RAG, Stacks, and `tfctl` as supporting architecture.
- Avoid implying the assistant is making final approval decisions.
- Avoid live HCP Terraform dependency unless auth and workspace names are confirmed before recording.
- Use `app-platform` as the main demo because it feels like real SRE/platform work.
