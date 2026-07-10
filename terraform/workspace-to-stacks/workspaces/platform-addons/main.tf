module "platform_addons" {
  source = "../../modules/platform-addons"

  environment    = var.environment
  cluster_name   = var.cluster_name
  enabled_addons = var.enabled_addons
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

variable "enabled_addons" {
  description = "Modeled platform add-ons."
  type        = list(string)
  default     = ["coredns", "vpc-cni", "kube-proxy", "aws-load-balancer-controller"]
}

output "addon_set_name" {
  description = "Add-on set name passed to app namespace workspace."
  value       = module.platform_addons.addon_set_name
}

output "enabled_addons" {
  description = "Enabled add-ons."
  value       = module.platform_addons.enabled_addons
}
