provider "aws" {
  region = var.aws_region
}

resource "aws_lb" "api" {
  name               = "payments-api"
  internal           = !var.public_load_balancer
  load_balancer_type = "application"
  subnets            = var.public_load_balancer ? var.public_subnet_ids : var.private_subnet_ids

  tags = var.common_tags
}

resource "aws_ecs_cluster" "main" {
  name = "payments-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

resource "aws_ecs_service" "api" {
  name            = "payments-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = "payments-api:42"
  desired_count   = var.desired_count

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  tags = var.common_tags
}

resource "aws_db_instance" "primary" {
  identifier              = "payments-primary"
  engine                  = "postgres"
  engine_version          = "15.5"
  instance_class          = var.db_instance_class
  allocated_storage       = 100
  storage_encrypted       = true
  db_subnet_group_name    = "payments-private"
  skip_final_snapshot     = false
  deletion_protection     = true
  backup_retention_period = 7

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  count = var.enable_latency_alarm ? 1 : 0

  alarm_name          = "payments-api-p95-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1.5
  alarm_description   = "Payments API p95 latency is above threshold"
  treat_missing_data  = "notBreaching"

  tags = var.common_tags
}
