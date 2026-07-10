terraform {
  required_version = ">= 1.13.0"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name where the namespace is created."
  type        = string
}

variable "addon_set_name" {
  description = "Platform add-on set that must exist before the namespace."
  type        = string
}

variable "namespace" {
  description = "Application namespace."
  type        = string
  default     = "hashibank"
}

resource "terraform_data" "namespace" {
  input = {
    environment    = var.environment
    cluster_name   = var.cluster_name
    addon_set_name = var.addon_set_name
    namespace      = var.namespace
  }
}

output "namespace" {
  description = "Modeled Kubernetes namespace."
  value       = terraform_data.namespace.output.namespace
}

output "service_account" {
  description = "Modeled application service account."
  value       = "${terraform_data.namespace.output.namespace}-${var.environment}"
}
