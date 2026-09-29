# OPA policy set for the ai-infra-copilot workspace.
#
# Distinct job from Sentinel:
#   This layer evaluates workspace-specific capacity governance using
#   Terraform's native OPA policy evaluation (no Sentinel runtime required).
#
# Enforcement level:
#   mandatory — must pass before any apply is allowed; no override path.
#   Use this to show the HCP Terraform-native policy check on stage.

policy "prod-capacity" {
  source            = "./prod-capacity.rego"
  enforcement_level = "mandatory"
}
