provider "aws" {
  region = var.aws_region
}

# ── Observability ────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/payments-api"
  retention_in_days = 30

  tags = var.common_tags
}

# ── IAM – task execution role ────────────────────────────────────────────────

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "payments-api-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ── Networking – task security group ────────────────────────────────────────

resource "aws_security_group" "ecs_tasks" {
  name        = "payments-api-ecs-tasks"
  description = "Egress-only security group for payments-api ECS tasks"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound (ECR pull, CloudWatch Logs, SSM)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

# ── ECS cluster ──────────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "main" {
  name = "payments-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

# ── ECS task definition ──────────────────────────────────────────────────────

resource "aws_ecs_task_definition" "api" {
  family                   = "payments-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "payments-api"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.common_tags
}

# ── ECS service ──────────────────────────────────────────────────────────────
# desired_count is the Terraform-declared baseline.
# Drift occurs when an operator manually changes this via the AWS console or
# CLI (e.g. during an incident scale-out). HCP Terraform Health detects the
# divergence and surfaces it for a codify-or-revert decision.
# No autoscaling is attached intentionally — it would mask the drift signal.

resource "aws_ecs_service" "api" {
  name            = "payments-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = var.assign_public_ip
  }

  tags = var.common_tags

  # Prevent Terraform from fighting back against manual scale events mid-demo.
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ── CloudWatch alarm – ECS CPU utilisation ───────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "api_cpu" {
  count = var.enable_cpu_alarm ? 1 : 0

  alarm_name          = "payments-api-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Payments API ECS service CPU above 70%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.api.name
  }

  tags = var.common_tags
}

# ── RDS (gated) ──────────────────────────────────────────────────────────────

resource "aws_db_instance" "primary" {
  count = var.create_runtime_resources ? 1 : 0

  identifier                  = "payments-primary"
  engine                      = "postgres"
  engine_version              = "15.5"
  instance_class              = var.db_instance_class
  allocated_storage           = 100
  storage_encrypted           = true
  username                    = var.db_username
  manage_master_user_password = true
  db_subnet_group_name        = "payments-private"
  skip_final_snapshot         = false
  deletion_protection         = true
  backup_retention_period     = 7

  tags = var.common_tags
}
