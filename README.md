# workshop-platform

Platform baseline infrastructure for the `workshop` project.

## Purpose

This repository owns VPC, EKS, IAM/OIDC, ingress, baseline observability, and
shared platform capabilities. It does not contain business logic or edge Lambdas.

## Main stack

- Terraform
- Kubernetes
- AWS

## Deployment strategy

- `feature/* -> stag`: Pull Request with Terraform validation and manifests
- `stag -> prod`: promotion Pull Request into `production`
- AWS OIDC authentication for pipelines

## Local documentation

- [docs/README.md](docs/README.md)
