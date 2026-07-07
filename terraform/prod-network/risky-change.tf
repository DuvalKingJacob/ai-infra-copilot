# This file is intentionally not used by default.
# It shows the kind of risky IAM expansion represented in the sample plan JSON.

data "aws_iam_policy_document" "deploy_bot_risky_example" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:*",
      "iam:PassRole",
    ]

    resources = ["*"]
  }
}

