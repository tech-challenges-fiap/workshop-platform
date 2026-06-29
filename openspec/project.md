# Project Context

## Repository

`workshop-platform` is the shared AWS and Kubernetes platform repository for the workshop service.

## Ownership

This repository owns: Terraform network/EKS/monitoring modules, Kubernetes baseline manifests, platform validation scripts, and platform documentation.

This repository does not own: application runtime behavior, Lambda handler logic, or managed database instances.

## OpenSpec Governance

OpenSpec is the canonical process for non-trivial changes. Product, architecture, contract, infrastructure, schema, workflow, and runtime behavior changes must start with an OpenSpec change under `openspec/changes/<change-id>/`.

Claude Code and other agents must not implement from informal intent alone. If a change is missing, ambiguous, or expands beyond the approved tasks, the agent must stop and raise the question to Hermes/Void.

## Primary Change Areas

terraform/, kubernetes/, scripts/, docs/, .ai/

## Validation Baseline

```bash
cd terraform && terraform fmt -check -recursive && terraform init -backend=false && terraform validate && cd .. && ./scripts/validate-k8s-manifests.sh
```

## Branching Baseline

Work starts from updated `origin/stag`, opens PRs into `stag`, and never pushes directly to `stag` or `prod`. Production remains promotion-only through `stag -> prod`.
