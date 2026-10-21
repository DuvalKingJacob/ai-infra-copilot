# ── ECS health verification (Day 2 operations) ──────────────────────────────
# A read-only Lambda plus a Terraform Action that invokes it, used to verify
# the payments-api ECS service after governed remediation (for example after
# the codified desired_count baseline has been applied).
#
# Nothing here references or modifies aws_ecs_service.api beyond reading its
# name/ARN. The action is deliberately NOT wired to any action_trigger; run it
# on demand, for example:
#
#   terraform apply -invoke=action.aws_lambda_invoke.verify_ecs_health
#
# or from the HCP Terraform Actions page. See docs/ecs-health-verification.md.
#
# A successful invocation only means the Lambda ran. The health verdict is the
# PASS/FAIL line ("ECS_HEALTH_VERDICT ...") in the log tail the action prints.

locals {
  verify_function_name = "payments-${var.environment}-verify-ecs-health"
  verify_source_dir    = "${path.module}/lambda/verify_ecs_health"
}

data "archive_file" "verify_ecs_health" {
  type        = "zip"
  source_file = "${local.verify_source_dir}/handler.py"
  output_path = "${path.module}/.build/verify_ecs_health.zip"
}

# ── Observability ────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "verify_ecs_health" {
  name              = "/aws/lambda/${local.verify_function_name}"
  retention_in_days = 30

  tags = var.common_tags
}

# ── IAM – Lambda execution role (least privilege, read-only) ────────────────

data "aws_iam_policy_document" "verify_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "verify_ecs_health" {
  name               = "${local.verify_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.verify_lambda_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "verify_ecs_health" {
  # DescribeServices supports resource-level permissions on the service ARN.
  statement {
    sid       = "DescribePaymentsApiServiceOnly"
    actions   = ["ecs:DescribeServices"]
    resources = [aws_ecs_service.api.id]
  }

  # The log group is managed above, so CreateLogGroup is intentionally absent.
  statement {
    sid     = "WriteOwnLogs"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      aws_cloudwatch_log_group.verify_ecs_health.arn,
      "${aws_cloudwatch_log_group.verify_ecs_health.arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_role_policy" "verify_ecs_health" {
  name   = "verify-ecs-health"
  role   = aws_iam_role.verify_ecs_health.id
  policy = data.aws_iam_policy_document.verify_ecs_health.json
}

# ── Lambda function ──────────────────────────────────────────────────────────

resource "aws_lambda_function" "verify_ecs_health" {
  function_name    = local.verify_function_name
  description      = "Read-only ECS service health verifier (ecs:DescribeServices). Returns PASS/FAIL."
  role             = aws_iam_role.verify_ecs_health.arn
  runtime          = "python3.12"
  handler          = "handler.lambda_handler"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 15
  filename         = data.archive_file.verify_ecs_health.output_path
  source_code_hash = data.archive_file.verify_ecs_health.output_base64sha256

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.verify_ecs_health.name
  }

  tags = var.common_tags

  depends_on = [aws_iam_role_policy.verify_ecs_health]
}

# ── Action (independently invocable; no action_trigger) ─────────────────────
# log_type = "Tail" is required: the action prints the last 4 KB of the Lambda
# log, which is where the PASS/FAIL verdict appears. The response payload
# itself is not displayed by the action.
#
# fail_on_fail = true makes a FAIL verdict raise inside the Lambda so the
# action (and the HCP Terraform run) errors instead of reporting a green
# invocation. Set var.verify_fail_on_fail = false to only report.

action "aws_lambda_invoke" "verify_ecs_health" {
  config {
    function_name = aws_lambda_function.verify_ecs_health.function_name
    log_type      = "Tail"
    payload = jsonencode({
      cluster             = aws_ecs_cluster.main.name
      service             = aws_ecs_service.api.name
      expected_task_count = coalesce(var.verify_expected_task_count, var.desired_count)
      fail_on_fail        = var.verify_fail_on_fail
    })
  }
}
