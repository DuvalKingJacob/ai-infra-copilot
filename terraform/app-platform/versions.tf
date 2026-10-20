terraform {
  # Actions (the action block and -invoke) require Terraform 1.14 or newer.
  required_version = ">= 1.14.0"

  required_providers {
    # aws_lambda_invoke shipped in 6.14.0; log_type = "Tail" output in the
    # action shipped in 6.19.0. Pinned to the 6.67 line that was validated.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.67.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

