# workshop-platform Architecture

## Role

`workshop-platform` is the shared infrastructure repository. It provisions the
AWS network and Kubernetes runtime foundation used by `workshop-app` and
published through `workshop-edge`.

## Boundaries

This repository owns:

- shared platform Terraform and naming
- VPC, subnets, route tables, EKS, managed nodes, IAM, and OIDC
- ingress-nginx installation and public load balancer exposure
- Kubernetes namespaces `stag` and `prod`
- Datadog cluster installation when enabled
- platform outputs required by app and edge deployment contracts

This repository does not own:

- application behavior, images, routes, or manifests beyond platform baseline
- edge handler implementation
- RDS, database credentials, migrations, or seed data

## Terraform Composition

The root Terraform module composes:

- `modules/network`: VPC, public/private subnets, internet gateway, route tables, and optional NAT gateway
- `modules/eks`: EKS control plane, managed node group, IAM roles, OIDC provider, core add-ons, and platform security groups
- root Kubernetes and Helm resources: namespaces, ingress-nginx, optional Datadog, and deploy access

The Terraform `environment` variable is fixed to `shared`. Runtime
environments are isolated inside the single EKS cluster through the `stag` and
`prod` namespaces.

## Cost Profile

The default configuration is optimized for minimum cost while keeping a real
EKS platform:

- `enable_nat_gateway = false`
- `node_subnet_tier = "public"`
- one managed node
- Datadog disabled

This avoids the fixed NAT Gateway cost. Use `node_subnet_tier = "private"` with
`enable_nat_gateway = true` when private node networking is required.

## Deployment Interfaces

`workshop-app` consumes:

- `cluster_name`
- `cluster_region`
- `deploy_role_arn`
- `namespace_stag`
- `namespace_prod`
- ingress hostname for the target environment

`workshop-edge` consumes:

- `ingress_hostname_stag`
- `ingress_hostname_prod`

`workshop-db` can consume:

- `vpc_id`
- `private_subnet_ids`
- `workload_security_group_id`

The database repository remains responsible for database provisioning and
secret ownership. This platform repository only exposes network and security
group contracts needed for connectivity.

## Environment Isolation

The cluster contains separate `stag` and `prod` namespaces. The generated
`deploy_role_arn` receives namespace-scoped edit access to those namespaces
through EKS access entries and access policy associations.

## Observability

Datadog is installed through Helm only when `enable_datadog` is true. In that
mode, `datadog_api_key` must come from a secure variable source or the
`DATADOG_API_KEY` GitHub Actions secret.
