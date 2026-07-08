# AI Agents Need an Authorization Layer, Not Just Better Prompts

AI infrastructure demos often start with a chatbot. The user asks a question, the model responds, and the demo feels impressive because the interface is simple.

But the moment that assistant becomes useful to an infrastructure team, the problem changes.

It is no longer just answering questions. It is reading internal docs, retrieving incident notes, inspecting Terraform state, checking Kubernetes services, proposing remediations, remembering context, and sometimes taking action.

At that point, the interesting question is not only:

> Can the model answer?

It is:

> What was the model allowed to see, what was the agent allowed to do, and who approved the risky parts?

That is the shift this project explores.

## From Chatbot To Operational Workflow

Platform teams do not need another generic chatbot. They need workflows that fit how infrastructure work actually happens.

A platform engineer might ask:

> What changed in production, what runbook applies, and should we roll anything back?

Answering that well may require several different capabilities:

- Search runbooks and postmortems.
- Understand customer impact.
- Inspect recent Terraform changes.
- Check Kubernetes service health.
- Separate facts from recommendations.
- Propose a rollback.
- Require approval before production changes.
- Leave an audit trail.

That is not a single model response. It is a system.

## RAG Creates A Context Access Problem

Retrieval-augmented generation is useful because it grounds answers in local knowledge. For infrastructure teams, that knowledge might include:

- Runbooks.
- Architecture notes.
- Incident reports.
- Terraform procedures.
- Customer impact summaries.
- Internal support guidance.

But RAG also creates a new access path.

If a user is not allowed to read the production postmortem, the RAG system should not retrieve that postmortem and send it to the model. Filtering the final answer is not enough. The context has already crossed a boundary.

That is the first lesson:

> Retrieved context is a protected resource.

In a serious system, authorization needs to happen before context reaches the model.

## MCP Creates A Tool Access Problem

MCP is exciting because it gives AI applications a structured way to connect to external tools and systems.

For infrastructure workflows, that could mean tools like:

- `terraform.get_recent_changes`
- `terraform.create_rollback_plan`
- `kubernetes.get_service_status`
- `runbook.search`
- `incident.list_recent_events`

That is powerful. It is also risky.

Once an assistant can call tools, the application needs to decide:

- Which actor is this agent acting for?
- Which tools can this actor call?
- Which resources can those tools inspect?
- Which actions are read-only?
- Which actions require approval?
- What should be logged?

MCP can make tools explicit and easier to integrate. It does not remove the need for domain authorization.

That is the second lesson:

> Tool access is an authorization boundary.

## Agents Create A Delegated Authority Problem

Agents are useful because they can plan across steps: retrieve context, call tools, synthesize results, and propose an action.

But delegation creates hard questions.

If Alice asks an assistant to roll back production, is the assistant acting with Alice's authority? With its own service identity? With a temporary session token? Can it call every tool Alice can call, or only the subset relevant to the task?

For infrastructure systems, the safest default is usually:

- Let the assistant inspect.
- Let the assistant explain.
- Let the assistant propose.
- Require approval before mutation.

That is why the demo separates answering from action. The assistant can create a rollback proposal, but it does not directly apply production changes.

That is the third lesson:

> Agents should not inherit unlimited operational authority from a prompt.

## Approval Is Part Of The Product Experience

Human approval is sometimes treated as a limitation. In infrastructure workflows, it is often the feature that makes the system usable.

Production teams already rely on plans, reviews, approvals, rollbacks, incident ownership, and audit trails. AI systems should fit into those patterns rather than bypass them.

The assistant should be able to say:

> I found the likely change, checked service status, generated a rollback proposal, and blocked execution pending approval from a platform lead.

That response is more trustworthy than:

> I applied the rollback.

The product experience should make risk visible.

## What I Built

I built a small local demo around AI-assisted infrastructure operations.

It includes:

- Permission-aware RAG over infrastructure documents.
- MCP-style Terraform and Kubernetes tools.
- Actor-specific authorization.
- Withheld documents and withheld tool results.
- Rollback proposal flow.
- Human approval by a platform lead.
- Audit trail across retrieval, tool calls, proposal, and approval.

The demo is intentionally local and simple. The point is not to create a production platform in a weekend. The point is to make the architecture legible.

The core workflow:

1. Alice, Bob, and Casey ask the same infrastructure question.
2. Each user gets different context based on permissions.
3. Terraform and Kubernetes tools are checked before results are exposed.
4. Risky actions become proposals.
5. Dana, the platform lead, can approve the proposal.
6. The audit log shows the path from prompt to decision.

## What I Would Change In Production

The local demo uses static data and a simple permission map. A production system would need stronger foundations.

I would add:

- OIDC authentication.
- Relationship-based authorization with SpiceDB/AuthZed.
- Real MCP servers for Terraform, Kubernetes, runbooks, and incident data.
- Vector or hybrid retrieval with chunk-level access control.
- Persistent audit logs.
- OpenTelemetry traces.
- Secrets isolation.
- Human approval workflows integrated with existing change management.
- Evals for prompt injection, unauthorized retrieval, unsafe tool use, and misleading answers.
- Memory controls for retention, deletion, and tenant isolation.

## The Bigger Takeaway

AI-native developer workflows are not just about models.

They are about the systems around the models:

- Context.
- Tools.
- Identity.
- Authorization.
- Approval.
- Auditability.
- Operational trust.

For infrastructure and platform teams, that is the real product surface.

The most important question is not:

> How smart is the assistant?

It is:

> Can this assistant participate safely in the workflows engineers already trust?
