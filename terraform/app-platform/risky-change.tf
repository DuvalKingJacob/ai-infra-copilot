# This file documents the risky-scenario variable values represented in
# data/terraform-plan.app-platform.json. It is illustrative only — not applied
# in the default workspace configuration.
#
# The drift demo story:
#   Terraform baseline: desired_count = 3
#   On-call engineer scales out manually to 6 during an incident.
#   HCP Terraform Health detects drift and surfaces a codify-or-revert decision.

locals {
  risky_change_examples = {
    desired_count = 1     # capacity reduction below safe baseline
    missing_tags  = true  # Owner and Environment omitted from common_tags
  }
}
