# Terraform Plan Review Demo

This repo includes a small Terraform plan review path to tie the AI infrastructure story back to platform engineering work.

## Goal

Show that an AI-native infrastructure copilot should be able to inspect and explain Terraform risk, but not directly apply changes.

## Files

- `data/terraform-plan.prod-network.json`
- `src/review-terraform-plan.mjs`

## Run

```bash
npm run terraform:review
```

The sample plan includes:

- A security group update that opens public ingress.
- An IAM policy update that introduces wildcard permissions.
- A CloudWatch alarm deletion.

The reviewer emits structured findings and a recommendation.

## Authorization-Gated Tool Path

The plan review is represented as an MCP-style tool:

```bash
npm run tool:call -- alice terraform.review_plan --provider=local
npm run tool:call -- bob terraform.review_plan --provider=local
```

With SpiceDB running:

```bash
npm run tool:call -- alice terraform.review_plan --provider=spicedb
npm run tool:call -- bob terraform.review_plan --provider=spicedb
```

Expected:

- Alice can access the plan review tool.
- Bob cannot access the production plan review tool.

## Product Point

The assistant should help platform teams understand blast radius:

- What resources changed?
- Which changes are risky?
- Which findings require human approval?
- Should apply be blocked?

The assistant should not directly run `terraform apply`.

## Interview Talking Point

> I used Terraform plan review because it maps directly to platform engineering workflows: plans, blast radius, peer review, approval, and auditability. The AI system can explain risk and propose next steps, but authorization controls who can inspect production plans and approval controls whether anything proceeds.

