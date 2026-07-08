terraform {
  required_version = ">= 1.13.0"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster runs."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for cluster nodes."
  type        = list(string)
}

variable "node_count" {
  description = "Modeled worker node count."
  type        = number
  default     = 3
}

resource "terraform_data" "cluster" {
  input = {
    environment        = var.environment
    vpc_id             = var.vpc_id
    private_subnet_ids = var.private_subnet_ids
    node_count         = var.node_count
  }
}

output "cluster_name" {
  description = "Modeled EKS cluster name."
  value       = "platform-${terraform_data.cluster.output.environment}"
}

output "cluster_endpoint" {
  description = "Modeled cluster endpoint."
  value       = "https://eks-${var.environment}.example.invalid"
}

