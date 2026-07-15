# Sentinel-Style Policy Examples

These policies are illustrative examples for the Terraform-native demo path.

They do not replace the local JavaScript reviewer. They show where production Terraform Enterprise policy checks would live in the workflow:

1. Authorization checks whether the actor can access production plan context or call an MCP-style tool.
2. Terraform plan review explains the proposed infrastructure change.
3. Sentinel-style policy evaluates whether the change violates organizational rules.
4. Human approval controls whether anything proceeds to apply.

In short:

- Authorization: who can use the capability?
- Sentinel: is this Terraform change allowed?

## Included Example Policies

- `no-public-ingress.sentinel`
- `no-wildcard-iam.sentinel`
- `no-prod-monitoring-delete.sentinel`
- `no-internet-facing-lb.sentinel`
- `no-prod-db-replacement.sentinel`
- `require-db-deletion-protection.sentinel`
- `minimum-prod-service-capacity.sentinel`
- `require-prod-tags.sentinel`
- `review-prod-replacement.sentinel`

For local Sentinel installation notes, see:

`docs/sentinel-local-setup.md`
