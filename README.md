# workshop-platform

`workshop-platform` owns the shared infrastructure baseline for the `workshop`
platform split. It is the future home for common platform capabilities such as
cluster, networking, ingress, and baseline runtime policies.

## What This Repository Owns

- Terraform baseline for shared platform infrastructure naming
- Kubernetes baseline manifests that belong to the platform layer
- platform-focused CI validation and deployment workflow

This repository does not own application domain logic, Lambda handlers, or
database instance provisioning.

## Current Scaffold Status

The current scaffold is intentionally small. Today it provides:

- a Terraform baseline in `terraform/`
- canonical naming inputs for project, repo, environment, and cluster suffix
- outputs for `name_prefix` and `eks_cluster_name`
- a Kubernetes base package in `kubernetes/base/`
- a manifest validation script in `scripts/validate-k8s-manifests.sh`
- CI workflows for Terraform validation, manifest checks, promotion policy, drift reporting, and deploy planning

It does not yet provision a full platform stack. The repository currently
defines the ownership, naming, and validation baseline for later platform work.

## Local Commands

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -var="environment=stag" -var="repo=platform"
cd ..
./scripts/validate-k8s-manifests.sh
```

## Delivery Flow

- `feature/* -> stag`: Pull Request validated by Terraform checks and Kubernetes manifest validation
- `stag -> prod`: promotion Pull Request allowed only from `stag`
- `push` to `stag` or `prod`: deployment workflow uses AWS OIDC and runs Terraform planning
- `prod` Pull Requests: drift-report and promotion-source workflows enforce branch discipline

## Documentation

- [docs/README.md](docs/README.md) - docs index and reading guide
- [docs/architecture.md](docs/architecture.md) - repository boundaries and target platform role
- [docs/development.md](docs/development.md) - Terraform/Kubernetes workflow, validation, and documentation rules
- [AGENTS.md](AGENTS.md) - instructions for AI contributors
