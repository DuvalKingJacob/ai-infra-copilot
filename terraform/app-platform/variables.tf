variable "aws_region" {
  description = "AWS region for the application platform sample."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"
}

variable "vpc_id" {
  description = "VPC ID for the application platform."
  type        = string
  default     = "vpc-1234567890abcdef0"
}

variable "private_subnet_ids" {
  description = "Private subnets for ECS tasks."
  type        = list(string)
  default     = ["subnet-private-a", "subnet-private-b"]
}

variable "public_subnet_ids" {
  description = "Public subnets reserved for internet-facing load balancing when explicitly approved."
  type        = list(string)
  default     = ["subnet-public-a", "subnet-public-b"]
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to Fargate tasks. Required when using public subnets (e.g. default VPC) so tasks can reach ECR and CloudWatch Logs."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Container image for the payments-api task definition. Defaults to the public Amazon ECS sample image."
  type        = string
  default     = "public.ecr.aws/amazonlinux/amazonlinux:latest"
}

variable "desired_count" {
  description = "Terraform-declared baseline task count for the ECS service. An on-call engineer scaling this manually produces the drift the demo detects."
  type        = number
  default     = 3
}

variable "create_runtime_resources" {
  description = "Whether to create the RDS instance. Keep false for stage demos; the ECS service runs without it."
  type        = bool
  default     = false
}

variable "enable_cpu_alarm" {
  description = "Whether to create the ECS CPU utilisation alarm."
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "RDS instance class. Only used when create_runtime_resources is true."
  type        = string
  default     = "db.r6g.large"
}

variable "db_username" {
  description = "Database admin username. Only used when create_runtime_resources is true."
  type        = string
  default     = "demo_admin"
}

variable "common_tags" {
  description = "Required tags applied to all production resources. Must include Environment, Owner, and ManagedBy to satisfy the require-prod-tags Sentinel policy."
  type        = map(string)
  default = {
    Environment = "production"
    Owner       = "platform"
    ManagedBy   = "terraform"
    Service     = "payments-api"
  }
}
