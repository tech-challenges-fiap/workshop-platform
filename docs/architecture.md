# workshop-platform Architecture

## Role

`workshop-platform` is the shared infrastructure repository. It provisions and
standardizes common runtime capabilities such as cluster foundations,
networking, ingress, IAM/OIDC, and baseline observability.

## Boundaries

This repository owns:

- shared platform Terraform and environment naming
- Kubernetes baseline manifests that belong to the platform layer
- platform-focused validation and deployment workflows

This repository does not own application behavior, handler implementation, or
database instance provisioning.

## Current Implementation Surface

Today the repository contains:

- `terraform/main.tf` naming baseline
- `terraform/variables.tf` for project, repo, environment, and resource suffix inputs
- `terraform/outputs.tf` exposing `name_prefix` and `eks_cluster_name`
- `kubernetes/base/kustomization.yaml`
- `kubernetes/base/namespace.yaml`
- `scripts/validate-k8s-manifests.sh`

## Current Scaffold vs Target State

Current scaffold:

- naming baseline only
- minimal Kubernetes namespace package
- simple manifest structure validation

Target state:

- shared infrastructure ownership separated from application and delivery concerns
- cluster/network/ingress conventions reusable across environments
- platform-level deployment and runtime standards for the workshop system

## Non-Goals

- Do not move application routes, handler implementation, or database provisioning into this repo.
- Do not document a full EKS or ingress stack as implemented unless Terraform defines it.
- Do not treat minimal Kubernetes manifests as proof of a complete runtime platform.
