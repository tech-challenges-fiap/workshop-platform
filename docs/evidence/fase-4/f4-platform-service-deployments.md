# Evidence: f4-platform-service-deployments

Date: 2026-07-17
Repo: `workshop-platform`
Change ID: `f4-platform-service-deployments`

## Summary

Implemented Kubernetes platform deployment baseline manifests for the Phase 4 Order Service (OS), Billing Service, and Execution Service as independently deployable services. The manifests provide ConfigMaps, ClusterIP Services, and Deployments with explicit placeholder images that downstream application delivery workflows must replace before live apply.

No application service code, business handlers, ingress routes, database resources, or correlation observability were added.

## Artifacts created/modified

- `openspec/changes/f4-platform-service-deployments/proposal.md`
- `openspec/changes/f4-platform-service-deployments/design.md`
- `openspec/changes/f4-platform-service-deployments/tasks.md`
- `openspec/changes/f4-platform-service-deployments/specs/platform-service-deployments/spec.md`
- `kubernetes/base/services/order-service/configmap.yaml`
- `kubernetes/base/services/order-service/service.yaml`
- `kubernetes/base/services/order-service/deployment.yaml`
- `kubernetes/base/services/billing-service/configmap.yaml`
- `kubernetes/base/services/billing-service/service.yaml`
- `kubernetes/base/services/billing-service/deployment.yaml`
- `kubernetes/base/services/execution-service/configmap.yaml`
- `kubernetes/base/services/execution-service/service.yaml`
- `kubernetes/base/services/execution-service/deployment.yaml`
- `kubernetes/base/kustomization.yaml`
- `scripts/validate-k8s-manifests.sh`
- `docs/architecture.md`
- `docs/evidence/fase-4/f4-platform-service-deployments.md`

## Validation

### OpenSpec pre-implementation

Command:

```bash
npx --yes @fission-ai/openspec validate f4-platform-service-deployments --strict
```

Result: PASS

Output:

```text
Change 'f4-platform-service-deployments' is valid
```

### OpenSpec post-implementation

Command:

```bash
npx --yes @fission-ai/openspec validate f4-platform-service-deployments --strict
```

Result: PASS

Output:

```text
Change 'f4-platform-service-deployments' is valid
```

### Terraform

Command:

```bash
cd terraform
terraform fmt -check -recursive && terraform init -backend=false && terraform validate
```

Result: PASS

Output excerpt:

```text
Terraform has been successfully initialized!
Success! The configuration is valid.
```

### Kubernetes manifest validation

Command:

```bash
./scripts/validate-k8s-manifests.sh
```

Result: PASS

Output:

```text
Validated Kubernetes manifests: 16
```

### Kustomize render

Command:

```bash
if command -v kustomize >/dev/null 2>&1; then
  kustomize build kubernetes/base >/tmp/workshop-platform-kustomize.yaml
elif command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize kubernetes/base >/tmp/workshop-platform-kustomize.yaml
else
  echo 'kustomize and kubectl not installed'
  exit 127
fi
```

Result: NOT RUN - tool unavailable in this environment.

Output:

```text
kustomize and kubectl not installed
```

## Archive status

Archived successfully.

Command:

```bash
npx --yes @fission-ai/openspec archive f4-platform-service-deployments --yes
```

Output:

```text
Task status: ✓ Complete

Specs to update:
  platform-service-deployments: create
Applying changes to openspec/specs/platform-service-deployments/spec.md:
  + 6 added
Totals: + 6, ~ 0, - 0, → 0
Specs updated successfully.
Change 'f4-platform-service-deployments' archived as '2026-07-17-f4-platform-service-deployments'.
```

Post-archive spec validation command:

```bash
npx --yes @fission-ai/openspec validate --specs --strict
```

Result: PASS

Output:

```text
- Validating...
✓ spec/platform-rabbitmq
✓ spec/platform-service-deployments
Totals: 2 passed, 0 failed (2 items)
```

Note: `npx --yes @fission-ai/openspec validate --strict` without an explicit target returned `Nothing to validate`; the successful post-archive validation used the documented `--specs --strict` target.
