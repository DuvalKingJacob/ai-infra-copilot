terraform {
  required_version = ">= 1.13.0"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to model."
  type        = number
  default     = 3
}

resource "terraform_data" "vpc" {
  input = {
    environment = var.environment
    cidr_block  = var.cidr_block
    az_count    = var.az_count
  }
}

output "vpc_id" {
  description = "Modeled VPC ID."
  value       = "vpc-${terraform_data.vpc.output.environment}"
}

output "private_subnet_ids" {
  description = "Modeled private subnet IDs."
  value = [
    for index in range(var.az_count) : "subnet-${var.environment}-private-${index + 1}"
  ]
}

output "public_subnet_ids" {
  description = "Modeled public subnet IDs."
  value = [
    for index in range(var.az_count) : "subnet-${var.environment}-public-${index + 1}"
  ]
}

