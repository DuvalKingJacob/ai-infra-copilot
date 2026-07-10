module "hashibank_app" {
  source = "../../modules/hashibank-app"

  environment     = var.environment
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  replicas        = var.replicas
  image_tag       = var.image_tag
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

variable "namespace" {
  description = "Namespace normally copied from the app namespace workspace output."
  type        = string
  default     = "hashibank"
}

variable "service_account" {
  description = "Service account normally copied from the app namespace workspace output."
  type        = string
  default     = "hashibank-prod"
}

variable "replicas" {
  description = "Modeled app replica count."
  type        = number
  default     = 6
}

variable "image_tag" {
  description = "Modeled HashiBank image tag."
  type        = string
  default     = "stable"
}

output "service_name" {
  description = "Modeled HashiBank service name."
  value       = module.hashibank_app.service_name
}

output "app_url" {
  description = "Modeled HashiBank URL."
  value       = module.hashibank_app.app_url
}

output "release_summary" {
  description = "Release summary passed to review systems."
  value       = module.hashibank_app.release_summary
}
