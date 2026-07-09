# Demo Script

## Setup

Open `demo/index.html` in a browser.

## 1. Same Prompt, Different Authorization

Select Alice and run:

`Check whether the payments service is healthy and whether there were recent Terraform changes.`

Point out:

- Alice can see production/platform docs.
- Alice can use the Terraform and Kubernetes MCP-style tools.
- The audit trail records document and tool decisions.

Switch to Bob and run the same prompt.

Point out:

- Bob gets support/customer context.
- Privileged Terraform data is withheld.

Switch to Casey and run the same prompt.

Point out:

- Casey gets only public context.
- The assistant is constrained by actor permissions.

## 2. Risky Action Becomes A Proposal

Select Alice and run:

`Create a rollback proposal for the last Terraform change.`

Point out:

- The assistant can propose a rollback.
- It does not apply the rollback.
- Approval is required for production-impacting action.

## 3. Human Approval

Switch to Dana.

Approve the proposal.

Point out:

- Dana has approval authority.
- The audit log records the approval event.
- The demo intentionally stops before execution.

## Closing Line

This is the product lesson:

> AI-native infrastructure workflows need clear boundaries around context, tools, actions, and approval.

## 4. Terraform Plan Review

Run:

```bash
make review
```

Point out:

- The plan includes public ingress, wildcard IAM, and monitoring deletion.
- The output is a review and recommendation, not an apply.
- This maps to familiar platform engineering workflows: plan, review, approve, audit.

## 5. Agent Workflow

Run:

```bash
node src/agent-workflow.mjs alice "Should we apply the Terraform change?" --provider=spicedb
node src/agent-workflow.mjs bob "Should we apply the Terraform change?" --provider=spicedb
```

Point out:

- The agent plans the workflow instead of answering in one step.
- It retrieves docs and calls tools only through authorization checks.
- Alice can get Terraform review output.
- Bob is denied production Terraform tool output.
- The workflow produces a proposal and audit trail, not a production mutation.
