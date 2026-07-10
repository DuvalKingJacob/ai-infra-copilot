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

variable "image_tag" {
  type = string
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

component "platform_addons" {
  source = "../modules/platform-addons"

  inputs = {
    environment  = var.environment
    cluster_name = component.eks_cluster.cluster_name
  }

  providers = {}
}

component "app_namespace" {
  source = "../modules/app-namespace"

  inputs = {
    environment    = var.environment
    cluster_name   = component.eks_cluster.cluster_name
    addon_set_name = component.platform_addons.addon_set_name
    namespace      = "hashibank"
  }

  providers = {}
}

component "hashibank_app" {
  source = "../modules/hashibank-app"

  inputs = {
    environment     = var.environment
    cluster_name    = component.eks_cluster.cluster_name
    namespace       = component.app_namespace.namespace
    service_account = component.app_namespace.service_account
    replicas        = var.replicas
    image_tag       = var.image_tag
  }

  providers = {}
}

output "app_url" {
  type  = string
  value = component.hashibank_app.app_url
}

output "component_graph" {
  type = object({
    network           = string
    cluster           = string
    platform_addons   = string
    namespace         = string
    application       = string
    application_url   = string
    application_image = string
  })

  value = {
    network           = component.vpc.vpc_id
    cluster           = component.eks_cluster.cluster_name
    platform_addons   = component.platform_addons.addon_set_name
    namespace         = component.app_namespace.namespace
    application       = component.hashibank_app.service_name
    application_url   = component.hashibank_app.app_url
    application_image = var.image_tag
  }
}
