# AI-Native Infrastructure Copilot Demo

Open `ai-infra-copilot-demo.html` in a browser. No install step is required.

## What It Demonstrates

This is a portfolio-oriented demo for AI-native infrastructure workflows. It shows how a platform assistant can combine:

- Permission-aware RAG over infrastructure docs.
- MCP-style Terraform and Kubernetes tools.
- Authorization checks before document context or tool results reach the model.
- Action proposals instead of direct production mutation.
- Human approval for risky actions.
- An audit trail across retrieval, tool calls, proposal, and approval.

## Demo Path

1. Select Alice and ask:
   `Check whether the payments service is healthy and whether there were recent Terraform changes.`

2. Switch to Bob and ask the same question.

3. Switch to Casey and ask the same question.

4. Select Alice and ask:
   `Create a rollback proposal for the last Terraform change.`

5. Switch to Dana and approve the proposal.

The point is that the assistant is not just a chatbot. It is a workflow with explicit boundaries around context, tools, and actions.

## Why MCP

MCP-style tools make infrastructure capabilities explicit. The assistant can inspect Terraform and Kubernetes context through named tools instead of hidden glue code.

The security lesson is that MCP does not remove the need for authorization. It makes tool access easier, which makes permission boundaries more important.

## Why RAG

Infrastructure answers should be grounded in runbooks, postmortems, support notes, and change procedures. RAG keeps the assistant tied to local operational knowledge.

The security lesson is that retrieved context is a protected resource. Unauthorized chunks should never be sent to the model.

## Why Approval Gates

The assistant can inspect and propose. It cannot directly apply a production rollback. Production-impacting actions require a human approver with the right permission.

## Production Extensions

- Replace the local permission map with SpiceDB/AuthZed.
- Use real embeddings or hybrid search.
- Connect the official Terraform MCP Server in read-only mode.
- Add a custom Kubernetes MCP server.
- Add OIDC authentication.
- Persist audit events.
- Add OpenTelemetry tracing.
- Add memory with retention, deletion, and authorization controls.

