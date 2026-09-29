# Sentinel policy set for the ai-infra-copilot workspace.
#
# Governance story:
#   Sentinel = existing org-wide controls that run regardless of who proposes
#              the change. These represent durable platform standards.
#   Terraform Policy (OPA) = workspace-level capacity rules evaluated at plan
#              time. See policies/opa/ for the TechXchange/TEC demo rules.
#
# Enforcement levels:
#   soft-mandatory  — blocks the run; an authorized reviewer can override
#   advisory        — surfaces a warning in the UI; never blocks

# ── Hard guardrails ──────────────────────────────────────────────────────────

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

# ── Advisory controls ────────────────────────────────────────────────────────

policy "require-db-deletion-protection" {
  source            = "./require-db-deletion-protection.sentinel"
  enforcement_level = "advisory"
}

policy "no-prod-monitoring-delete" {
  source            = "./no-prod-monitoring-delete.sentinel"
  enforcement_level = "advisory"
}

policy "no-wildcard-iam" {
  source            = "./no-wildcard-iam.sentinel"
  enforcement_level = "advisory"
}
