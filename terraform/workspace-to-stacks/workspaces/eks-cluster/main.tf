module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  node_count         = var.node_count
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID normally copied from the VPC workspace output."
  type        = string
  default     = "vpc-prod"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs normally copied from the VPC workspace output."
  type        = list(string)
  default     = ["subnet-prod-private-1", "subnet-prod-private-2", "subnet-prod-private-3"]
}

variable "node_count" {
  description = "Modeled worker node count."
  type        = number
  default     = 6
}

output "cluster_name" {
  description = "Cluster name passed to the app workspace."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Cluster endpoint passed to the app workspace."
  value       = module.eks.cluster_endpoint
}

