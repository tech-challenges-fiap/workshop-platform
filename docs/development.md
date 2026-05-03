# Developing In workshop-platform

## Prerequisites

- Terraform `>= 1.14.0`
- AWS credentials for real plans and applies
- a POSIX shell to run `scripts/validate-k8s-manifests.sh`

## Local Workflow

Validate Terraform without remote state:

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Validate the Kubernetes manifest structure:

```bash
cd ..
./scripts/validate-k8s-manifests.sh
```

Plan a real environment when AWS credentials are available:

```bash
cd terraform
terraform init -reconfigure -backend-config=environments/stag/backend.hcl.example
terraform plan -var-file=environments/stag/terraform.tfvars.example
```

## Terraform Inputs

Important root variables:

- `environment`: fixed to `shared` because `stag` and `prod` are Kubernetes namespaces in one cluster
- `aws_region`: AWS region for providers and backend
- `vpc_cidr`: CIDR block for the platform VPC
- `enable_nat_gateway`: enables private subnet internet egress through NAT
- `node_subnet_tier`: `public` for lowest cost or `private` when NAT/VPC endpoints exist
- `cluster_version`: EKS Kubernetes version
- `node_*`: managed node group scaling and instance type inputs
- `enable_datadog`: installs Datadog when true
- `datadog_api_key`: required when Datadog is enabled

Do not add database resources here. Use `vpc_id`, `private_subnet_ids`, and
`workload_security_group_id` outputs to wire database connectivity in
`workshop-db`.

## CI Behavior

- `pr-validation.yml` runs Terraform formatting, initialization, validation, and manifest validation.
- `deploy.yml` runs on `stag` and `prod`, prepares backend configuration from GitHub variables, plans, and applies the shared Terraform stack.
- `promotion-source.yml` and `drift-report.yml` protect the production promotion path.

The deploy workflow expects `AWS_REGION`, `AWS_ROLE_ARN`, `TF_STATE_BUCKET`,
`TF_STATE_KEY`, and `ENABLE_DATADOG`. Configure the same Terraform state bucket
and key for both `stag` and `prod` GitHub environments so the repository keeps
one shared cluster. When Datadog is enabled, set the `DATADOG_API_KEY` secret.

`stop-platform.yml` can be run manually and is also scheduled nightly. It
targets the shared cluster, so it reduces runtime capacity for both `stag` and
`prod`. It calls the stop script to scale the managed node group to zero and
delete the ingress-nginx Service, which releases the Network Load Balancer. It
does not stop the EKS control plane; only Terraform destroy removes that hourly
cluster cost.

## Branching and Delivery Expectations

- Build features from `feature/*` or `codex/*` branches
- Open Pull Requests into `stag` for normal integration
- Promote to `prod` only from `stag`
- Expect `pr-validation.yml` to run Terraform validation and Kubernetes manifest checks
- Expect `deploy.yml` to apply Terraform after merges to `stag` or `prod`
- Expect stop workflows to reduce runtime cost outside demo windows without deleting Terraform-owned infrastructure state
- Expect `promotion-source.yml` and `drift-report.yml` to protect production promotions

## Documentation Rules

- Write all documentation in English
- Keep docs faithful to Terraform and manifests that exist in this repository
- When Terraform, manifest layout, commands, or workflows change, update the docs in the same change
- Keep application deployment behavior and database provisioning documented in their owning repositories

## When To Update Documentation

Update documentation when you change:

- Terraform variables, outputs, modules, resources, or naming rules
- Kubernetes manifests or validation behavior
- deployment workflow behavior
- repository ownership boundaries
- AI contributor guidance in `AGENTS.md` or `.ai/`
