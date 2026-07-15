# Demo-only example of the old workspace handoff pattern.
# This file is not applied. It gives the Stacks walkthrough a concrete before-state to compare against the Stack component references.

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "example"

    workspaces = {
      name = "hashibank-vpc-prod"
    }
  }
}

module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  node_count         = var.node_count
}
