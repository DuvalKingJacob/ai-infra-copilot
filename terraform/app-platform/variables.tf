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
  description = "Private subnets for ECS tasks and the database."
  type        = list(string)
  default     = ["subnet-private-a", "subnet-private-b"]
}

variable "public_subnet_ids" {
  description = "Public subnets for internet-facing load balancing when explicitly approved."
  type        = list(string)
  default     = ["subnet-public-a", "subnet-public-b"]
}

variable "create_runtime_resources" {
  description = "Whether to create apply-sensitive runtime resources such as the ALB, ECS service, and RDS instance. Keep false for safe demo applies."
  type        = bool
  default     = false
}

variable "public_load_balancer" {
  description = "Whether the application load balancer is internet-facing."
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "Desired ECS task count for the API service."
  type        = number
  default     = 6
}

variable "ecs_task_definition" {
  description = "Existing ECS task definition family:revision used when create_runtime_resources is true."
  type        = string
  default     = "payments-api:42"
}

variable "db_instance_class" {
  description = "RDS instance class for the application database."
  type        = string
  default     = "db.r6g.large"
}

variable "db_username" {
  description = "Database admin username used when create_runtime_resources is true."
  type        = string
  default     = "demo_admin"
}

variable "enable_latency_alarm" {
  description = "Whether to create the API latency alarm."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Required tags for production resources."
  type        = map(string)
  default = {
    Service     = "payments-api"
    Environment = "production"
    Owner       = "platform"
    ManagedBy   = "terraform"
  }
}
