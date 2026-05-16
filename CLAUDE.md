# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`workshop-platform` owns shared AWS and Kubernetes infrastructure for the `workshop` service. It provisions the platform layer consumed by `workshop-app`, `workshop-edge`, and `workshop-db` — but does not own application code, Lambda handlers, or database instances.

**In scope:** Terraform (`terraform/`), Kubernetes manifests (`kubernetes/`), platform validation scripts (`scripts/`), platform-focused documentation.

**Out of scope:** application runtime behavior, edge handler logic, database provisioning.

## Commands

Run before proposing any Terraform or Kubernetes change (no AWS credentials required):

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
cd ..
./scripts/validate-k8s-manifests.sh
```

Environment plan with real backend and AWS credentials:

```bash
cd terraform
terraform init -reconfigure -backend-config=environments/stag/backend.hcl.example
terraform plan -var-file=environments/stag/terraform.tfvars.example
```

Reduce runtime cost when the cluster is idle:

```bash
AWS_PROFILE=workshop-eks-admin AWS_REGION=sa-east-1 ./scripts/stop-platform-runtime.sh
```

This scales the node group to zero and releases the NLB. The EKS control plane keeps running; destroy the Terraform stack to stop it entirely.

## Architecture

### Infrastructure Stack

One shared Terraform stack provisions both `stag` and `prod` — they are Kubernetes namespaces in a single cluster, not separate clusters. Both environments share the same `TF_STATE_BUCKET` and `TF_STATE_KEY`.

**Terraform modules:**
- `terraform/modules/network/` — VPC, public/private subnets, route tables, optional NAT gateway
- `terraform/modules/eks/` — EKS control plane, managed node group, IAM roles, OIDC provider, security groups

**Root Terraform resources:** Kubernetes namespace creation, ingress-nginx Helm deployment (v4.13.0), optional Datadog Helm chart (v3.128.0), IAM deploy role with namespace-scoped edit access.

**Key cost-control variables:** `enable_nat_gateway` (default `false`), `node_subnet_tier` (default `"public"`), `enable_datadog` (default `false`). The example configs use one `t3.small` node, Kubernetes 1.33, in `sa-east-1`.

### Platform Outputs

The stack exposes these outputs consumed by dependent repos:
- `cluster_name`, `cluster_region`, `deploy_role_arn` → `workshop-app`
- `ingress_hostname_stag`, `ingress_hostname_prod` → `workshop-edge`
- `vpc_id`, `private_subnet_ids`, `public_subnet_ids`, `workload_security_group_id` → `workshop-db`

### Kubernetes Manifests

`kubernetes/base/` defines the `stag` and `prod` namespace contract via Kustomize. This is the baseline consumed by application repos.

### CI/CD Workflows

- **`pr-validation.yml`** — Terraform fmt/init/validate + K8s manifest validation on every PR
- **`deploy.yml`** — Applies Terraform on push to `stag` or `prod` via AWS OIDC; includes cluster-restoration logic when the EKS cluster was deleted outside Terraform
- **`stop-platform.yml`** — Manual or scheduled cost-reduction workflow
- **`create-promotion-pr.yml`** — Manual workflow to open the `stag → prod` PR (requires `PROMOTION_PR_TOKEN` secret)
- **`drift-report.yml`** / **`promotion-source.yml`** — Guard `prod` to allow only `stag`-based PRs

## Branching and Delivery

- Always `git fetch origin --prune` before starting work; branch from updated `origin/stag`.
- Open all feature, fix, docs, and maintenance PRs into `stag` — never directly to `prod`.
- Promotion is always `stag → prod` via merge commit (no squash or rebase).
- If a `stag → prod` PR conflicts, do not create a direct branch into `prod`; inspect the conflict ancestry first.
- Before saying a task is done, check the PR's required CI statuses. If CI fails, attempt one fix; if still failing, stop and report the details.
- When reporting completion, include: branch name, PR URL, CI status, and any remaining blocker.

## Documentation

Update `README.md`, `docs/`, and `.ai/` when changing Terraform interfaces, Kubernetes manifest layout, validation commands, workflow behavior, or repository boundaries.
