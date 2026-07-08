# Workspace To Stacks Migration Map

## Starting Point

```text
platform-prod-vpc workspace
  outputs: vpc_id, private_subnet_ids, public_subnet_ids

platform-prod-eks workspace
  inputs: vpc_id, private_subnet_ids
  outputs: cluster_name, cluster_endpoint

payments-prod-app workspace
  inputs: vpc_id, cluster_name
  outputs: service_name, app_url
```

## Pain

- The dependency graph is real, but it is implied.
- The rollout order is external to Terraform.
- Cross-workspace values are copied through remote state, variables, CI, or runbooks.
- Plan review happens one workspace at a time, even though the service is one operational unit.

## Target Stack

```text
deployment "prod"
  component "vpc"
    -> component "eks_cluster"
      -> component "app"
```

## Migration Steps

1. Extract shared logic from each workspace into modules.
2. Keep the existing workspaces running while the modules stabilize.
3. Create a Stack component configuration that wires modules together explicitly.
4. Define `dev` and `prod` deployments with environment-specific inputs.
5. Run Stack plans and compare them to current workspace plans.
6. Move one lower-risk environment first.
7. Promote production after policy, approval, and rollback paths are documented.

## AI Review Question

This is the question the assistant should help answer:

> This app plan changes replicas and depends on EKS and VPC outputs. What is the blast radius, and should this be approved?

The assistant can explain dependencies and risk. It should not apply the Stack.

