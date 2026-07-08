module "app" {
  source = "../../modules/app"

  environment  = var.environment
  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  replicas     = var.replicas
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "Cluster name normally copied from the EKS workspace output."
  type        = string
  default     = "platform-prod"
}

variable "vpc_id" {
  description = "VPC ID normally copied from the VPC workspace output."
  type        = string
  default     = "vpc-prod"
}

variable "replicas" {
  description = "Modeled app replica count."
  type        = number
  default     = 6
}

output "service_name" {
  description = "Modeled service name."
  value       = module.app.service_name
}

output "app_url" {
  description = "Modeled app URL."
  value       = module.app.app_url
}

