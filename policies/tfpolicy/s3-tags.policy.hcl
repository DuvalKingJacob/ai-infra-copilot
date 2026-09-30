resource_policy "aws_s3_bucket" "require_environment_tag" {
  enforce {
    condition     = core::can(attrs.tags) ? core::contains(core::keys(attrs.tags), "Environment") : false
    error_message = "S3 bucket must have an 'Environment' tag."
  }
}
