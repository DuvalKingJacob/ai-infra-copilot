module "app_namespace" {
  source = "../../modules/app-namespace"

  environment    = var.environment
  cluster_name   = var.cluster_name
  addon_set_name = var.addon_set_name
  namespace      = var.namespace
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

variable "addon_set_name" {
  description = "Add-on set name normally copied from the platform add-ons workspace output."
  type        = string
  default     = "platform-addons-prod"
}

variable "namespace" {
  description = "Application namespace."
  type        = string
  default     = "hashibank"
}

output "namespace" {
  description = "Namespace passed to the app workspace."
  value       = module.app_namespace.namespace
}

output "service_account" {
  description = "Service account passed to the app workspace."
  value       = module.app_namespace.service_account
}
