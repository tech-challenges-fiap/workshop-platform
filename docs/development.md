# Developing In workshop-platform

## Prerequisites

- Terraform `>= 1.14.0`
- a POSIX shell to run `scripts/validate-k8s-manifests.sh`

## Local Workflow

Validate the Terraform baseline:

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -var="environment=stag" -var="repo=platform"
```

Validate the Kubernetes manifest structure:

```bash
cd ..
./scripts/validate-k8s-manifests.sh
```

## What The Commands Do

- `terraform fmt -check -recursive` verifies Terraform formatting
- `terraform init -backend=false` initializes providers without requiring a remote backend
- `terraform validate` checks the Terraform configuration
- `terraform plan ...` validates the environment-specific platform contract used by CI
- `./scripts/validate-k8s-manifests.sh` ensures every manifest under `kubernetes/` contains `apiVersion` and `kind`

## Branching and Delivery Expectations

- Build features from `feature/*` branches
- Open Pull Requests into `stag` for normal integration
- Promote to `prod` only from `stag`
- Expect `pr-validation.yml` to run Terraform validation and Kubernetes manifest checks
- Expect `deploy.yml` to use AWS OIDC and plan Terraform with environment-specific variables
- Expect `promotion-source.yml` and `drift-report.yml` to protect production promotions

## Documentation Rules

- Write all documentation in English
- Keep docs faithful to the platform baseline that exists today
- When Terraform, manifest layout, commands, or workflows change, update the docs in the same change
- Do not describe cluster capabilities as implemented unless Terraform or Kubernetes manifests define them

## When To Update Documentation

Update documentation when you change:

- Terraform variables, outputs, or naming rules
- Kubernetes manifests or validation behavior
- deployment workflow behavior
- repository ownership boundaries
- AI contributor guidance in `AGENTS.md` or `.ai/`
