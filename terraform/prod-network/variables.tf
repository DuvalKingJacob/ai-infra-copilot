variable "aws_region" {
  description = "AWS region for the sample production network."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID that owns the payments ingress security group."
  type        = string
  default     = "vpc-1234567890abcdef0"
}

variable "payments_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the payments service over HTTPS."
  type        = list(string)
  default     = ["10.40.0.0/16"]
}

variable "payments_service_arn" {
  description = "Production ECS service ARN used by the deploy bot."
  type        = string
  default     = "arn:aws:ecs:us-east-1:111122223333:service/prod/payments-api"
}

variable "enable_latency_alarm" {
  description = "Whether to create the payments latency alarm."
  type        = bool
  default     = true
}

