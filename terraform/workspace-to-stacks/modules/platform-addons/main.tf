terraform {
  required_version = ">= 1.13.0"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name where platform add-ons are installed."
  type        = string
}

variable "enabled_addons" {
  description = "Modeled platform add-ons."
  type        = list(string)
  default     = ["coredns", "vpc-cni", "kube-proxy", "aws-load-balancer-controller"]
}

resource "terraform_data" "addons" {
  input = {
    environment    = var.environment
    cluster_name   = var.cluster_name
    enabled_addons = var.enabled_addons
  }
}

output "addon_set_name" {
  description = "Modeled add-on set name."
  value       = "platform-addons-${terraform_data.addons.output.environment}"
}

output "enabled_addons" {
  description = "Modeled enabled add-ons."
  value       = terraform_data.addons.output.enabled_addons
}
