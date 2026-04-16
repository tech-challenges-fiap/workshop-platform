# AGENTS.md

## Mission

Work in `workshop-platform` as a shared infrastructure repository. Keep this
repo focused on platform-level Terraform, Kubernetes baseline manifests, and
shared delivery conventions.

## Scope Boundaries

In scope:

- Terraform in `terraform/`
- Kubernetes manifests in `kubernetes/`
- platform validation scripts in `scripts/`
- platform-focused documentation

Out of scope:

- application runtime behavior
- handler implementation and edge-specific integrations
- database provisioning

## Read First

- `README.md`
- `docs/architecture.md`
- `docs/development.md`
- `terraform/main.tf`
- `terraform/variables.tf`
- `kubernetes/base/kustomization.yaml`
- `scripts/validate-k8s-manifests.sh`

## Validation Commands

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -var="environment=stag" -var="repo=platform"
cd ..
./scripts/validate-k8s-manifests.sh
```

Run all relevant validation for any Terraform or Kubernetes change. For
documentation-only changes, still verify that documented commands and paths are
correct.

## Writing Rules

- Write docs and AI guidance in English
- Do not invent platform resources that the repo does not define
- Keep platform responsibilities separate from application, delivery, and database concerns
- Treat target-state architecture as intent, not as implemented fact

## Documentation Expectations

Update `README.md`, `docs/`, and `.ai/` when you change:

- Terraform interfaces
- Kubernetes manifest layout
- validation commands
- deployment workflow behavior
- repository boundaries
