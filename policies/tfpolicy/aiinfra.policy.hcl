policy_set "ai-infra-capacity-policy" {
  policy "prod-ecs-capacity-bounds" {
    source            = "./prod-capacity.tfpolicy"
    enforcement_level = "soft-mandatory"
  }

  policy "require-s3-production-tags" {
    source            = "./s3-tags.tfpolicy"
    enforcement_level = "soft-mandatory"
  }
}
