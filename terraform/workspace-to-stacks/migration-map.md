# Workspace To Stacks Migration Map

## Starting Point

```text
platform-prod-vpc workspace
  outputs: vpc_id, private_subnet_ids, public_subnet_ids

platform-prod-eks workspace
  inputs: vpc_id, private_subnet_ids
  outputs: cluster_name, cluster_endpoint

platform-prod-addons workspace
  inputs: cluster_name
  outputs: addon_set_name, enabled_addons

hashibank-prod-namespace workspace
  inputs: cluster_name, addon_set_name
  outputs: namespace, service_account

hashibank-prod-app workspace
  inputs: cluster_name, namespace, service_account
  outputs: service_name, app_url, release_summary
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
      -> component "platform_addons"
        -> component "app_namespace"
          -> component "hashibank_app"
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

> This HashiBank app plan changes replicas and depends on namespace, add-ons, EKS, and VPC outputs. What is the blast radius, and should this be approved?

The assistant can explain dependencies and risk. It should not apply the Stack.
