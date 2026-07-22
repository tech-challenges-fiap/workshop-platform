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

The Kubernetes base includes platform manifest directories for namespaces,
RabbitMQ, Phase 4 services, and shared observability conventions. The
observability conventions are configuration placeholders only; service
repositories still own correlation ID middleware, RabbitMQ propagation, log
formatting, and metrics emission.

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

- `pr-validation.yml` runs Terraform formatting, initialization, validation, `terraform plan -refresh=false`, and manifest validation.
- `deploy.yml` runs on `stag` and `prod`, prepares backend configuration from GitHub variables, plans, and applies the shared Terraform stack.
- When the shared EKS cluster is missing but still present in Terraform state, `deploy.yml` restores the AWS/EKS targets before planning the Kubernetes and Helm resources.
- After apply, `deploy.yml` updates kubeconfig and verifies the cluster is reachable, `stag` and `prod` namespaces exist, ingress-nginx is healthy, and Datadog is healthy only when `ENABLE_DATADOG` is `true`.
- `promotion-source.yml` and `drift-report.yml` protect the production promotion path.

The deploy workflow expects `AWS_REGION`, `AWS_ROLE_ARN`, `TF_STATE_BUCKET`,
`TF_STATE_KEY`, and `ENABLE_DATADOG`. Configure the same Terraform state bucket
and key for both `stag` and `prod` GitHub environments so the repository keeps
one shared cluster. When Datadog is enabled, set the `DATADOG_API_KEY` secret.

## Branching and Delivery Expectations

- Build features from `feature/*` or `codex/*` branches
- Open Pull Requests into `stag` for normal integration
- Promote to `prod` only from `stag`
- Expect `pr-validation.yml` to run Terraform validation, a no-refresh plan, and Kubernetes manifest checks
- Expect `deploy.yml` to apply Terraform and run platform smoke checks after merges to `stag` or `prod`
- Expect `promotion-source.yml` and `drift-report.yml` to protect production promotions

## Documentation Rules

- Write all documentation in English
- Keep docs faithful to Terraform and manifests that exist in this repository
- When Terraform, manifest layout, commands, or workflows change, update the docs in the same change
- Keep application deployment behavior and database provisioning documented in their owning repositories
- Keep application observability instrumentation documented in owning service repositories; this repository only documents platform-level correlation configuration and metadata conventions

## When To Update Documentation

Update documentation when you change:

- Terraform variables, outputs, modules, resources, or naming rules
- Kubernetes manifests or validation behavior
- deployment workflow behavior
- repository ownership boundaries
- AI contributor guidance in `AGENTS.md` or `.ai/`
