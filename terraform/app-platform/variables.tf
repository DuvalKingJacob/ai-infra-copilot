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

variable "desired_count" {
  description = "Desired ECS task count for the API service."
  type        = number
  default     = 6
}

variable "db_instance_class" {
  description = "RDS instance class for the application database."
  type        = string
  default     = "db.r6g.large"
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

