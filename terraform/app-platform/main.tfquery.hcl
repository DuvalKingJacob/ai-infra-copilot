# Terraform Search Configuration for Sterling S3 Assets
#
# This configuration enables Terraform Search to discover existing S3 storage assets
# in the environment so that unmanaged infrastructure can be brought under IaC governance.

list "aws_s3_bucket" "sterling_property_assets" {
  provider = aws

  config {}
}
