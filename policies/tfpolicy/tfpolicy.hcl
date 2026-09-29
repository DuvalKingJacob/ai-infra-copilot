policy_set "ai-infra-copilot-capacity" {
  policy "prod-ecs-capacity-bounds" {
    source            = "./prod-capacity.tfpolicy"
    enforcement_level = "soft-mandatory"
  }
}
