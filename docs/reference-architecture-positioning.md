# Reference Architecture Positioning

This project is best understood as a reference architecture for trustworthy AI-assisted infrastructure operations.

It is not primarily a chatbot demo.

It is a way to explore how these pieces fit together:

- Terraform context
- permission-aware retrieval
- MCP-style tool access
- relationship-based authorization
- agent workflow boundaries
- human approval
- auditability

## Core Thesis

Once an AI assistant can retrieve internal context and call operational tools, authorization becomes part of the product architecture.

## Operating Model

```text
User request
  -> actor context
  -> permission-aware retrieval
  -> authorized tool access
  -> Terraform plan review
  -> action proposal
  -> human approval
  -> audit trail
```

## Terraform Angle

Terraform is a useful proving ground because it already has strong operational concepts:

- plan before apply
- blast radius
- policy checks
- workspace boundaries
- run approvals
- audit history

AI assistance should fit into those concepts rather than bypass them.

## MCP Angle

MCP-style tools make infrastructure capabilities easier for agents to call.

That raises important questions:

- Which actor is the agent acting for?
- Which tools can that actor call?
- Which workspace or environment can those tools inspect?
- Which outputs should be withheld?
- Which actions require approval?

## Authorization Angle

This repo treats authorization as a first-class part of the architecture:

- docs are checked before becoming model-visible context
- tools are checked before returning results
- proposals and approvals are separate stages
- mutation is intentionally out of scope

## Useful Demo Sentence

> This reference architecture shows how an AI-assisted infrastructure workflow can retrieve context, inspect Terraform risk, call tools, and propose action while keeping authorization, approval, and auditability explicit.

