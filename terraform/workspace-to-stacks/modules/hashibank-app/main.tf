terraform {
  required_version = ">= 1.13.0"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name that hosts HashiBank."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for HashiBank."
  type        = string
}

variable "service_account" {
  description = "Service account used by the app."
  type        = string
}

variable "replicas" {
  description = "Modeled app replica count."
  type        = number
  default     = 3
}

variable "image_tag" {
  description = "Modeled HashiBank image tag."
  type        = string
  default     = "stable"
}

resource "terraform_data" "hashibank" {
  input = {
    environment     = var.environment
    cluster_name    = var.cluster_name
    namespace       = var.namespace
    service_account = var.service_account
    replicas        = var.replicas
    image_tag       = var.image_tag
  }
}

output "service_name" {
  description = "Modeled HashiBank service name."
  value       = "hashibank-${terraform_data.hashibank.output.environment}"
}

output "app_url" {
  description = "Modeled HashiBank URL."
  value       = "https://hashibank-${var.environment}.example.invalid"
}

output "release_summary" {
  description = "Modeled release summary for AI review."
  value = {
    service_name = "hashibank-${terraform_data.hashibank.output.environment}"
    namespace    = terraform_data.hashibank.output.namespace
    replicas     = terraform_data.hashibank.output.replicas
    image_tag    = terraform_data.hashibank.output.image_tag
  }
}
