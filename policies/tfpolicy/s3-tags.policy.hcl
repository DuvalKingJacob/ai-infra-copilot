# Production tagging governance policy for S3 storage assets.
#
# Governance story:
#   Ensures all S3 buckets (managed, unmanaged discovered via Search, or proposed)
#   have mandatory platform governance tags ('Environment' and 'Owner').
#   Evaluates both standard plan changes (core.plan.resource_changes) and
#   discovered/unmanaged resources evaluated during Search queries.

policy "require-s3-production-tags" {
  enforcement_level = "soft-mandatory"
}

locals {
  # 1. Match from core.plan.resource_changes (standard plan & generated starter config plans)
  plan_s3_changes = try(core.plan.resource_changes, [])

  # 2. Match from core.resources (direct resource model if exposed by Search query runtime)
  direct_resources = try(core.resources, [])

  # Combine candidate resource representations
  all_candidates = concat(
    [for r in local.plan_s3_changes : r if try(r.type, r.resource_type, "") == "aws_s3_bucket"],
    [for r in local.direct_resources : r if try(r.type, r.resource_type, "") == "aws_s3_bucket"]
  )
}

enforce {
  for_each = local.all_candidates
  each.key = "s3_required_tags"

  condition = (
    # Check tags across potential object paths (change.after.tags, tags, or values.tags)
    try(each.value.change.after.tags.Environment != null && each.value.change.after.tags.Environment != "", false) ||
    try(each.value.tags.Environment != null && each.value.tags.Environment != "", false) ||
    try(each.value.values.tags.Environment != null && each.value.values.tags.Environment != "", false)
  ) && (
    try(each.value.change.after.tags.Owner != null && each.value.change.after.tags.Owner != "", false) ||
    try(each.value.tags.Owner != null && each.value.tags.Owner != "", false) ||
    try(each.value.values.tags.Owner != null && each.value.values.tags.Owner != "", false)
  )

  error_message = "S3 bucket '${try(each.value.address, each.value.name, "discovered-bucket")}' is missing mandatory governance tags ('Environment', 'Owner'). All production storage assets must declare an owner and target environment."
}
