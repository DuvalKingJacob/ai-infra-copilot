variable "environment" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az_count" {
  type = number
}

variable "node_count" {
  type = number
}

variable "replicas" {
  type = number
}

component "vpc" {
  source = "../modules/vpc"

  inputs = {
    environment = var.environment
    cidr_block  = var.cidr_block
    az_count    = var.az_count
  }

  providers = {}
}

component "eks_cluster" {
  source = "../modules/eks"

  inputs = {
    environment        = var.environment
    vpc_id             = component.vpc.vpc_id
    private_subnet_ids = component.vpc.private_subnet_ids
    node_count         = var.node_count
  }

  providers = {}
}

component "app" {
  source = "../modules/app"

  inputs = {
    environment  = var.environment
    cluster_name = component.eks_cluster.cluster_name
    vpc_id        = component.vpc.vpc_id
    replicas      = var.replicas
  }

  providers = {}
}

output "app_url" {
  type  = string
  value = component.app.app_url
}

