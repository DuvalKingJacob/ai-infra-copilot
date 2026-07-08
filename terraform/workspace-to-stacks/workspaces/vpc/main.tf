module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  cidr_block  = var.cidr_block
  az_count    = var.az_count
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "cidr_block" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to model."
  type        = number
  default     = 3
}

output "vpc_id" {
  description = "VPC ID passed to downstream workspaces."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs passed to the EKS workspace."
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs exposed for load balancers."
  value       = module.vpc.public_subnet_ids
}

