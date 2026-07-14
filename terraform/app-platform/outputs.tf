output "service_name" {
  description = "ECS service name used in the sample."
  value       = var.create_runtime_resources ? aws_ecs_service.api[0].name : "runtime resources disabled"
}

output "database_identifier" {
  description = "Primary database identifier used in the sample."
  value       = var.create_runtime_resources ? aws_db_instance.primary[0].identifier : "runtime resources disabled"
}
