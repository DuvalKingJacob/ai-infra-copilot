# Terraform Policy Examples (tfpolicy)

These policies are the live governance layer for the TechXchange/TEC drift demo.
They run in HCP Terraform at plan time using the native Terraform policy framework —
the same HCL syntax as Terraform configuration itself.

## Why tfpolicy

tfpolicy is the direction HashiCorp is investing in for policy as code. It uses HCL,
supports three enforcement levels (`hard-mandatory`, `soft-mandatory`, `advisory`),
evaluates resource relationships without raw Rego, and works with Terraform Stacks.

For greenfield teams or teams migrating from Sentinel or OPA, tfpolicy is the recommended path.

## Registered Policy Sets

### `prod-capacity.tfpolicy` — `soft-mandatory`

Enforces production capacity bounds for the `payments-api` ECS service.
`desired_count` must be between 2 and 10.

**Demo story:** After drift is detected (Terraform declares 3, AWS is running 6),
the operator codifies `desired_count = 6`. This policy confirms 6 is within the
approved production range before the change is applied. Codifying 1 or 20 would
block the run with a clear message.

