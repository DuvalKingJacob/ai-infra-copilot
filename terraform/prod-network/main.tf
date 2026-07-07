provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "payments_ingress" {
  name        = "payments-ingress"
  description = "HTTPS ingress for the production payments API"
  vpc_id      = var.vpc_id

  ingress {
    description = "Payments API HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.payments_ingress_cidr_blocks
  }

  egress {
    description = "Allow egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Service     = "payments-api"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

data "aws_iam_policy_document" "deploy_bot" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:UpdateService",
    ]

    resources = [
      var.payments_service_arn,
    ]
  }
}

resource "aws_iam_policy" "deploy_bot" {
  name        = "payments-prod-deploy-bot"
  description = "Scoped permissions for the production payments deploy bot"
  policy      = data.aws_iam_policy_document.deploy_bot.json
}

resource "aws_cloudwatch_metric_alarm" "payments_latency" {
  count = var.enable_latency_alarm ? 1 : 0

  alarm_name          = "payments-api-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1.5
  alarm_description   = "Payments API p95 latency is above threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    Service = "payments-api"
  }
}

