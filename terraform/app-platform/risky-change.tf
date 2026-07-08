# This file is intentionally illustrative and not required for the default plan.
# It mirrors the risky changes represented in data/terraform-plan.app-platform.json:
# public load balancer exposure, database replacement, capacity reduction,
# monitoring removal, and missing production tags.

locals {
  risky_change_examples = {
    public_load_balancer = true
    desired_count        = 1
    db_instance_class    = "db.t4g.micro"
    enable_latency_alarm = false
  }
}

