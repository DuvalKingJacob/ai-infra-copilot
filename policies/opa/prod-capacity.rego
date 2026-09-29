package terraform

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# Production ECS capacity bounds for the payments-api service.
#
# Rules:
#   1. desired_count must be at least 2 (minimum viable redundancy)
#   2. desired_count must not exceed 10 (cost/capacity ceiling for this workspace)
#
# Story context:
#   After drift is detected (3 declared, 6 running), the operator proposes
#   codifying desired_count = 6. This policy confirms 6 is within the approved
#   production range before the change is applied.
#
#   If someone tried to codify desired_count = 1 or desired_count = 20,
#   this policy would block the run and explain why.

minimum_capacity = 2
maximum_capacity = 10

deny contains msg if {
	some change in input.resource_changes
	change.type == "aws_ecs_service"
	change.change.after != null
	change.change.after.desired_count < minimum_capacity
	msg := sprintf(
		"ECS service '%s' desired_count is %d — minimum allowed for production is %d.",
		[change.address, change.change.after.desired_count, minimum_capacity],
	)
}

deny contains msg if {
	some change in input.resource_changes
	change.type == "aws_ecs_service"
	change.change.after != null
	change.change.after.desired_count > maximum_capacity
	msg := sprintf(
		"ECS service '%s' desired_count is %d — maximum allowed for this workspace is %d. Request an exception or use autoscaling.",
		[change.address, change.change.after.desired_count, maximum_capacity],
	)
}
