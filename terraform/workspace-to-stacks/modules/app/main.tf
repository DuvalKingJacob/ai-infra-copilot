terraform {
  required_version = ">= 1.13.0"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name that hosts the app."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by the app platform."
  type        = string
}

variable "replicas" {
  description = "Modeled app replica count."
  type        = number
  default     = 3
}

resource "terraform_data" "app" {
  input = {
    environment  = var.environment
    cluster_name = var.cluster_name
    vpc_id       = var.vpc_id
    replicas     = var.replicas
  }
}

output "service_name" {
  description = "Modeled service name."
  value       = "payments-${terraform_data.app.output.environment}"
}

output "app_url" {
  description = "Modeled app URL."
  value       = "https://payments-${var.environment}.example.invalid"
}

