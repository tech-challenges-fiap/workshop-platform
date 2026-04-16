# workshop-platform Architecture

## Role in the Split

`workshop-platform` is the shared infrastructure repository for the workshop
split. Its long-term role is to provision and standardize common runtime
capabilities such as cluster foundations, networking, ingress, IAM/OIDC, and
baseline observability.

## Boundaries

This repository owns:

- shared platform Terraform and environment naming
- Kubernetes baseline manifests that belong to the platform layer
- platform-focused validation and deployment workflows

This repository does not own:

- workshop application/domain behavior
- edge handlers and external adapter logic
- database instance provisioning

## Current Implementation Surface

Today the repository contains:

- `terraform/main.tf` naming baseline
- `terraform/variables.tf` for project, repo, environment, and resource suffix inputs
- `terraform/outputs.tf` exposing `name_prefix` and `eks_cluster_name`
- `kubernetes/base/kustomization.yaml`
- `kubernetes/base/namespace.yaml`
- `scripts/validate-k8s-manifests.sh`

## Dependencies and Interactions

- `workshop-app` is expected to run on infrastructure standardized here over time.
- `workshop-edge` may consume shared platform capabilities from this repo but should keep edge-specific adapters in its own repository.
- `workshop-db` remains responsible for database provisioning even when platform and database deployments interact operationally.

## Current Scaffold vs Target State

Current scaffold:

- naming baseline only
- minimal Kubernetes namespace package
- simple manifest structure validation

Target state derived from `14soat-group56`:

- shared infrastructure ownership separated from application and edge concerns
- cluster/network/ingress conventions reusable across environments
- platform-level deployment and runtime standards for the workshop system

## Non-Goals

- Do not move app routes, Lambda handlers, or database provisioning into this repo.
- Do not document a full EKS or ingress stack as implemented unless Terraform defines it.
- Do not treat minimal Kubernetes manifests as proof of a complete runtime platform.
