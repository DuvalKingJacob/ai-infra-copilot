output "payments_ingress_security_group_id" {
  description = "Security group ID for payments ingress."
  value       = aws_security_group.payments_ingress.id
}

output "deploy_bot_policy_arn" {
  description = "IAM policy ARN for the payments deploy bot."
  value       = aws_iam_policy.deploy_bot.arn
}

