# Sentinel policy set for the ai-infra-copilot workspace.
#
# Governance story:
#   Sentinel = org-wide controls that run regardless of who proposes the change.
#   tfpolicy (policies/tfpolicy/) = workspace-specific capacity ceiling in HCL.
#
# Only hard policies are registered here. Advisory noise removed intentionally —
# every policy that appears on stage should have a clear job in the demo story.

policy "require-prod-tags" {
  source            = "./require-prod-tags.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "minimum-prod-service-capacity" {
  source            = "./minimum-prod-service-capacity.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "no-prod-db-replacement" {
  source            = "./no-prod-db-replacement.sentinel"
  enforcement_level = "soft-mandatory"
}
