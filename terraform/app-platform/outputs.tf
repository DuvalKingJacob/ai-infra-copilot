output "service_name" {
  description = "ECS service name used in the sample."
  value       = aws_ecs_service.api.name
}

output "database_identifier" {
  description = "Primary database identifier used in the sample."
  value       = aws_db_instance.primary.identifier
}

