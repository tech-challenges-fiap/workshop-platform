# workshop-platform

[![prod/stag](https://raw.githubusercontent.com/tech-challenges-fiap/workshop-platform/badges/badges/prod-stag-sync.svg?v=2)](https://github.com/tech-challenges-fiap/workshop-platform/compare/prod...stag)

`workshop-platform` owns shared AWS and Kubernetes infrastructure for the
`workshop` service. It provisions the platform layer used by application and
edge repositories, without owning application code or database instances.

## What This Repository Owns

- VPC, public subnets, private subnets, route tables, and optional NAT egress
- EKS cluster, managed node group, IAM roles, and cluster OIDC provider
- Kubernetes namespaces for `stag` and `prod`
- ingress-nginx as the shared HTTP ingress controller
- optional Datadog installation through the Datadog Helm chart
- platform outputs consumed by `workshop-app` and `workshop-edge`
- platform-focused CI validation and deployment workflows

This repository does not own application runtime behavior, Lambda handlers, or
database instance provisioning.

## Provisioned Surface

The Terraform stack provisions one shared platform cluster and exposes:

- `cluster_name`
- `cluster_region`
- `deploy_role_arn`
- `ingress_hostname_stag`
- `ingress_hostname_prod`
- `namespace_stag`
- `namespace_prod`
- `vpc_id`
- `private_subnet_ids`
- `public_subnet_ids`
- `workload_security_group_id`

Use `workload_security_group_id` when `workshop-db` needs to allow platform
workloads to connect to PostgreSQL. Database resources and credentials remain
owned by `workshop-db`.

## Local Commands

Minimal validation without touching remote state:

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
cd ..
./scripts/validate-k8s-manifests.sh
```

Environment plan with real backend and AWS access:

```bash
cd terraform
terraform init -reconfigure -backend-config=environments/stag/backend.hcl.example
terraform plan -var-file=environments/stag/terraform.tfvars.example
```

The default examples use the lowest-cost viable profile:

- one managed node
- no NAT Gateway
- nodes in public subnets
- Datadog disabled

Set `enable_nat_gateway = true` and `node_subnet_tier = "private"` when the
environment should favor private node networking over minimum cost. Set
`enable_datadog = true` and provide `datadog_api_key` through a secure tfvars
source when Datadog should be installed.

Reduce platform runtime cost when the cluster is not being used:

```bash
AWS_PROFILE=workshop-eks-admin AWS_REGION=sa-east-1 ./scripts/stop-platform-runtime.sh
```

The stop script targets the shared EKS cluster and affects both `stag` and
`prod`. It scales the managed node group to zero and deletes the ingress-nginx
Service so the Network Load Balancer is released. The EKS control plane itself
cannot be stopped; destroy the Terraform stack when the cluster should stop
incurring control-plane cost.

## Delivery Flow

- `feature/* -> stag`: Pull Request validated by Terraform checks and Kubernetes manifest validation
- `stag -> prod`: promotion Pull Request allowed only from `stag`
- `push` to `stag` or `prod`: deployment workflow uses AWS OIDC and applies Terraform
- If the shared EKS cluster was deleted outside Terraform, the deployment workflow first restores the AWS/EKS targets and then applies the Kubernetes resources.
- After apply, the deployment workflow updates kubeconfig and checks cluster reachability, `stag` and `prod` namespaces, ingress-nginx rollout health, and Datadog only when `ENABLE_DATADOG` is `true`.
- `Stop Platform`: manual or scheduled workflow reduces shared cluster runtime cost for both `stag` and `prod`
- `prod` Pull Requests: drift-report and promotion-source workflows enforce branch discipline
- `Create Promotion PR`: manual workflow that opens the `stag` to `prod` promotion PR when one does not already exist

The deployment workflow expects repository or environment variables. Use the
same `TF_STATE_BUCKET` and `TF_STATE_KEY` for `stag` and `prod` deployments so
promotion applies the same shared platform stack instead of creating separate
clusters.

- `AWS_REGION`
- `AWS_ROLE_ARN`
- `TF_STATE_BUCKET`
- `TF_STATE_KEY`
- `ENABLE_DATADOG`

When `ENABLE_DATADOG` is `true`, it also expects the `DATADOG_API_KEY` secret.

The `Create Promotion PR` workflow requires the `PROMOTION_PR_TOKEN` repository
secret. Use a fine-grained GitHub token with access to this repository and
pull request read/write permission.

## Documentation

- [docs/README.md](docs/README.md) - docs index and reading guide
- [docs/architecture.md](docs/architecture.md) - repository boundaries and platform architecture
- [docs/development.md](docs/development.md) - Terraform/Kubernetes workflow, validation, and documentation rules
- [AGENTS.md](AGENTS.md) - instructions for AI contributors
