# AI-Native Infrastructure Copilot Build Plan

This plan turns the portfolio brief into a practical sequence of small, impressive milestones.

## Build Philosophy

Optimize for:

- A hiring manager understanding the project in five minutes.
- A developer believing the workflow could be useful.
- Architecture that is easy to explain.
- Security and authorization as first-class product decisions.
- A repo that documents why each choice was made.

Avoid:

- Generic chatbot patterns.
- Framework sprawl.
- Real production credentials in the demo.
- Destructive actions.
- Unclear agent magic.

## Milestone 1: Permission-Aware RAG

Goal:

Show that the same infrastructure question produces different authorized context for different users.

Build:

- Small corpus of runbooks, incident notes, Terraform notes, and customer-facing docs.
- User selector with roles and permissions.
- Retriever that finds candidate docs.
- Authorization filter before answer generation.
- Audit log with allowed and denied context.

Success criteria:

- Alice, Bob, and Casey ask the same question.
- The UI clearly shows candidate documents, denied documents, and model-visible context.
- The README explains why post-answer filtering is not enough.

## Milestone 2: MCP Tool Router

Goal:

Show that the assistant can inspect infrastructure through explicit tools.

Build:

- MCP-style tool adapter for Terraform workspace data.
- MCP-style tool adapter for Kubernetes service status.
- Tool call audit log.
- Tool authorization checks.

Example tools:

- `terraform.list_workspaces`
- `terraform.get_recent_changes`
- `terraform.create_rollback_plan`
- `kubernetes.get_service_status`
- `kubernetes.list_recent_events`

Success criteria:

- The assistant can answer questions using both docs and tool outputs.
- Unauthorized tool calls are denied before execution.
- The audit log separates retrieval decisions from tool decisions.

## Milestone 3: Agent Workflow

Goal:

Separate retrieval, reasoning, and action.

Build:

- Simple planner that decides whether a question needs docs, tools, or an action proposal.
- Reasoning step that synthesizes citations and tool results.
- Action proposal step for risky requests.

Success criteria:

- The code and UI show distinct stages: retrieve, inspect, propose, approve.
- The assistant does not directly mutate infrastructure.

## Milestone 4: Human Approval

Goal:

Demonstrate safe handling of destructive or production-impacting actions.

Build:

- Approval queue.
- Approver user with explicit permission.
- Denial reason when a user lacks approval authority.
- Final audit event for approved or rejected action.

Success criteria:

- “Roll back production” creates a proposal.
- Alice can propose but not auto-apply.
- Dana can approve.
- Casey is denied.

## Milestone 5: Portfolio Polish

Goal:

Turn the project into something sendable.

Build:

- Clean README.
- Architecture diagram.
- Three-minute demo script.
- Sample prompts.
- Security model.
- Architectural decision records.
- Blog post draft.
- Short roadmap.

Success criteria:

- The repo answers:
  - Why MCP?
  - Why RAG?
  - Why authorization here?
  - What would change in production?
  - What are the failure modes?

## Suggested First Week

### Day 1

Refactor the current Secure RAG HTML demo into a repo-shaped project:

- `/app`
- `/data`
- `/docs`
- `/adr`

### Day 2

Add more realistic infrastructure docs:

- Terraform change note.
- Kubernetes service runbook.
- Production outage postmortem.
- Support-facing incident summary.

### Day 3

Add tool-call simulation:

- Mock Terraform workspace data.
- Mock Kubernetes service data.
- Authorization around each tool.

### Day 4

Add action proposal flow:

- Create rollback proposal.
- Require approval.
- Log approval decision.

### Day 5

Polish:

- README.
- Demo script.
- Architecture diagram.
- Blog outline.

## What To Say In Interviews

The project started from a simple question:

> What changes when AI assistants can access internal context and operational tools?

The answer:

> Retrieval, tool use, memory, and actions all become authorization problems.

The point is not that every AI workflow needs a huge security platform from day one. The point is that serious AI-native developer workflows need clear boundaries around:

- What context the model can see.
- What tools the agent can call.
- Which identity the agent acts under.
- Which actions require approval.
- What gets audited.

