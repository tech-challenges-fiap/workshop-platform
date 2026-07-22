## 1. OpenSpec

- [x] 1.1 Create proposal, design, tasks, and spec delta for `platform-service-deployments`.
- [x] 1.2 Validate the change with `npx --yes @fission-ai/openspec validate f4-platform-service-deployments --strict` before implementation. PASSED.

## 2. Kubernetes Service Deployment Manifests

- [x] 2.1 Create `kubernetes/base/services/order-service/` with ConfigMap, Service, and Deployment manifests for OS.
- [x] 2.2 Create `kubernetes/base/services/billing-service/` with ConfigMap, Service, and Deployment manifests for Billing.
- [x] 2.3 Create `kubernetes/base/services/execution-service/` with ConfigMap, Service, and Deployment manifests for Execution.
- [x] 2.4 Keep manifests limited to platform deployment shape and placeholder image/runtime wiring; do not add application code, handlers, ingress, database resources, or correlation observability.

## 3. Kustomize Wiring

- [x] 3.1 Add the new service ConfigMap, Service, and Deployment manifests to `kubernetes/base/kustomization.yaml`.

## 4. Validation Script

- [x] 4.1 Update `scripts/validate-k8s-manifests.sh` so the three service manifest directories are required and included in manifest validation.

## 5. Documentation

- [x] 5.1 Update `docs/architecture.md` with the OS/Billing/Execution deployment topology, service DNS names, placeholder image contract, and ownership boundaries.

## 6. Validation and Evidence

- [x] 6.1 Re-run strict OpenSpec validation for the change. PASSED.
- [x] 6.2 Run Terraform validation if applicable or record why Terraform is not applicable. PASSED: `terraform fmt -check -recursive && terraform init -backend=false && terraform validate`.
- [x] 6.3 Run `./scripts/validate-k8s-manifests.sh`. PASSED: validated 16 manifests.
- [x] 6.4 Render `kubernetes/base` with Kustomize if available. NOT AVAILABLE locally: neither `kustomize` nor `kubectl` is installed.
- [x] 6.5 Create `docs/evidence/fase-4/f4-platform-service-deployments.md` with commands and results.
- [x] 6.6 If all validation passes, archive the change and validate specs. PASSED after archive.
