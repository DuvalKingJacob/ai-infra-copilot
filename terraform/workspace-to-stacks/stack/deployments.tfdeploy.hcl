deployment_auto_approve "no_destroys" {
  check {
    condition = context.plan.changes.remove == 0
    reason    = "Plan removes ${context.plan.changes.remove} resources."
  }
}

deployment_group "development" {
  auto_approve_checks = [
    deployment_auto_approve.no_destroys,
  ]
}

deployment_group "production" {
  auto_approve_checks = []
}

deployment "dev" {
  inputs = {
    environment = "dev"
    cidr_block  = "10.20.0.0/16"
    az_count    = 2
    node_count  = 3
    replicas    = 2
  }

  deployment_group = deployment_group.development
}

deployment "prod" {
  inputs = {
    environment = "prod"
    cidr_block  = "10.40.0.0/16"
    az_count    = 3
    node_count  = 6
    replicas    = 6
  }

  deployment_group = deployment_group.production
}

