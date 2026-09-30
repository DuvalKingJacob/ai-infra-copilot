# Production capacity policy for the payments-api ECS service.
#
# Governance story:
#   This is the workspace-specific capacity guardrail written in HCL —
#   the same language as the Terraform config itself. No new syntax to learn.
#   This policy handles the capacity ceiling specific to this workspace's production budget.
#
# Demo flow:
#   Drift detected: desired_count = 3 (Terraform) vs 6 (AWS)
#   Operator codifies 6 as the new baseline → this policy passes (2 ≤ 6 ≤ 10)
#   Operator mistakenly codifies 1 → soft-mandatory blocks with clear message
#   Operator mistakenly codifies 20 → soft-mandatory blocks with clear message

policy "prod-ecs-capacity-bounds" {
  enforcement_level = "soft-mandatory"
}

locals {
  ecs_service_changes = [
    for change in core.plan.resource_changes :
    change if change.type == "aws_ecs_service" && change.change.after != null
  ]

  minimum_capacity = 2
  maximum_capacity = 10
}

enforce {
  for_each = local.ecs_service_changes
  each.key = "ecs_service_capacity"

  condition = (
    each.value.change.after.desired_count >= local.minimum_capacity &&
    each.value.change.after.desired_count <= local.maximum_capacity
  )

  error_message = "ECS service '${each.value.address}' desired_count is ${each.value.change.after.desired_count}. Production capacity must be between ${local.minimum_capacity} and ${local.maximum_capacity} tasks. To exceed this ceiling, request an exception through the platform team."
}
