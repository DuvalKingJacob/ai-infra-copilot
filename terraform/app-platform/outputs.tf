output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.api.name
}

output "task_definition_arn" {
  description = "ARN of the active task definition revision."
  value       = aws_ecs_task_definition.api.arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "log_group_name" {
  description = "CloudWatch log group receiving ECS task stdout/stderr."
  value       = aws_cloudwatch_log_group.api.name
}

output "database_identifier" {
  description = "Primary database identifier. Empty when create_runtime_resources is false."
  value       = var.create_runtime_resources ? aws_db_instance.primary[0].identifier : ""
}
