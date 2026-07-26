## 1. OpenSpec

- [x] 1.1 Create proposal, design, tasks, and spec deltas for `platform-correlation-observability`.
- [x] 1.2 Validate the change with `npx --yes @fission-ai/openspec validate f4-platform-correlation-observability --strict` before implementation. PASSED.

## 2. Kubernetes Correlation Observability Manifests

- [x] 2.1 Add a shared Kubernetes ConfigMap under `kubernetes/base/observability/` containing correlation ID header/message/log/metrics naming conventions and target-state defaults.
- [x] 2.2 Update OS, Billing, and Execution Deployments to consume the shared ConfigMap without replacing their service-specific ConfigMaps.
- [x] 2.3 Add common platform labels and annotations for correlation observability to OS, Billing, and Execution Deployment metadata and Pod templates.
- [x] 2.4 Keep manifests limited to configuration placeholders and metadata; do not add app code, database resources, ingress, dashboards, alert rules, collectors, or claim live centralized tracing/logging unless already present.

## 3. Kustomize and Validation

- [x] 3.1 Wire the shared observability ConfigMap into `kubernetes/base/kustomization.yaml`.
- [x] 3.2 Update `scripts/validate-k8s-manifests.sh` so the observability manifest directory is required and included in manifest validation.

## 4. Documentation

- [x] 4.1 Update platform architecture/development documentation with correlation propagation conventions, Kubernetes configuration contract, and non-goals.

## 5. Validation and Evidence

- [x] 5.1 Re-run strict OpenSpec validation for the change. PASSED.
- [x] 5.2 Run `./scripts/validate-k8s-manifests.sh`. PASSED: validated 17 manifests.
- [x] 5.3 Run Terraform validation if Terraform changed, otherwise record why Terraform validation is not applicable. NOT APPLICABLE: no Terraform files changed.
- [x] 5.4 Render `kubernetes/base` with Kustomize if `kustomize` or `kubectl` is available; otherwise record tool unavailability. SKIPPED: neither `kustomize` nor `kubectl` is available locally.
- [x] 5.5 Create `docs/evidence/fase-4/f4-platform-correlation-observability.md` with commands and results.
- [x] 5.6 If all validation passes, archive the change and validate specs with `npx --yes @fission-ai/openspec validate --specs --strict`. PASSED after archive.
