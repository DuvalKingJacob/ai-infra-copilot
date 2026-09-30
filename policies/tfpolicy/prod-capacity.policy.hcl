resource_policy "aws_ecs_service" "prod_capacity_bounds" {
  enforce {
    condition     = core::can(attrs.desired_count) ? attrs.desired_count >= 2 && attrs.desired_count <= 10 : true
    error_message = "ECS service desired_count must be between 2 and 10 tasks."
  }
}
