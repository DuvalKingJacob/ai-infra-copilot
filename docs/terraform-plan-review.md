# Terraform Plan Review Demo

This repo includes a Terraform-native plan review path to tie the AI infrastructure story back to platform engineering work.

## Goal

Show that an AI-assisted infrastructure workflow should be able to inspect and explain Terraform risk, but not directly apply changes.

The hero path should feel like a normal Terraform workflow:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
make review PLAN=plan.json
make report PLAN=plan.json REPORT=outputs/terraform-plan-review-report.md
```

The JavaScript is the assistant layer. Terraform is the center of gravity.

## Files

- `terraform/prod-network/*.tf`
- `data/terraform-plan.prod-network.json`
- `src/review-terraform-plan.mjs`
- `src/write-terraform-report.mjs`
- `src/terraform-plan-reviewer.mjs`
- `policies/sentinel/*.sentinel`

The `.tf` files provide the real Terraform scenario. The sample plan JSON represents the risky proposed change that the reviewer inspects.

There are two included scenarios:

- `terraform/prod-network`: small focused security/IAM/monitoring review.
- `terraform/app-platform`: richer SRE-style service, database, load balancer, capacity, and observability review.
- `terraform/workspace-to-stacks`: workspace-to-Stacks migration story for VPC, EKS, and app components.

## Run

```bash
make review
make report
```

Run the richer app-platform scenario:

```bash
make review-app
make report-app
```

`make review` prints structured JSON. `make report` writes a practitioner-readable Markdown report:

```bash
outputs/terraform-plan-review-report.md
```

The sample plan includes:

- A security group update that opens public ingress.
- An IAM policy update that introduces wildcard permissions.
- A CloudWatch alarm deletion.

The Terraform source lives at:

```bash
terraform/prod-network
```

You can inspect and format it with:

```bash
terraform -chdir=terraform/prod-network fmt
terraform -chdir=terraform/prod-network validate
```

`terraform validate` requires the AWS provider plugin. If provider installation fails, make sure your local machine can reach `registry.terraform.io`, then run:

```bash
terraform -chdir=terraform/prod-network init -backend=false
terraform -chdir=terraform/prod-network validate
```

The reviewer emits structured findings, Sentinel-style policy signals, and a recommendation.

## Sentinel-Style Policy Layer

The sample policy files live in:

```bash
policies/sentinel
```

They illustrate where Terraform Enterprise policy checks would sit in a production workflow:

- `no-public-ingress.sentinel`
- `no-wildcard-iam.sentinel`
- `no-prod-monitoring-delete.sentinel`
- `no-internet-facing-lb.sentinel`
- `no-prod-db-replacement.sentinel`
- `require-db-deletion-protection.sentinel`
- `minimum-prod-service-capacity.sentinel`
- `require-prod-tags.sentinel`

These policies do not conflict with SpiceDB/AuthZed because they answer a different question:

- SpiceDB/AuthZed: who can inspect this plan or call this tool?
- Sentinel: is this Terraform change allowed?

That distinction is the demo's core governance point.

Sentinel local setup notes live in:

```bash
docs/sentinel-local-setup.md
```

## Authorization-Gated Tool Path

The plan review is represented as an MCP-style tool:

```bash
make tool-check-local
```

With SpiceDB running:

```bash
make tool-check
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

## Report Shape

The Markdown report includes:

- Summary
- Risk findings
- Policy checks
- Blast radius
- Approval required
- What the agent did not do
- Architecture note

## Interview Talking Point

> I used Terraform plan review because it maps directly to platform engineering workflows: plans, blast radius, peer review, policy checks, approval, and auditability. The AI system can explain risk and propose next steps, but authorization controls who can inspect production plans, policy controls whether the change is acceptable, and approval controls whether anything proceeds.
