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

policy_set "ai-infra-capacity-policy-compat" {
  policy "prod-ecs-capacity-bounds-hcl" {
    source            = "./prod-capacity.policy.hcl"
    enforcement_level = "soft-mandatory"
  }

  policy "require-s3-production-tags-hcl" {
    source            = "./s3-tags.policy.hcl"
    enforcement_level = "soft-mandatory"
  }
}
