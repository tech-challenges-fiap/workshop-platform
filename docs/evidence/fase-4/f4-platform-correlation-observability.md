# Evidence: f4-platform-correlation-observability

## Scope

Implemented platform-level correlation observability conventions for Phase 4 service manifests in `workshop-platform`.

This change adds Kubernetes configuration placeholders and metadata only. It does not add application code, database resources, ingress resources, dashboards, alert rules, collectors, OpenTelemetry Collector resources, or Datadog runtime configuration.

## Commands and Results

### OpenSpec validation before implementation

```bash
npx --yes @fission-ai/openspec validate f4-platform-correlation-observability --strict
```

Result:

```text
Change 'f4-platform-correlation-observability' is valid
```

### OpenSpec validation after implementation

```bash
npx --yes @fission-ai/openspec validate f4-platform-correlation-observability --strict
```

Result:

```text
Change 'f4-platform-correlation-observability' is valid
```

### Kubernetes manifest validation

```bash
./scripts/validate-k8s-manifests.sh
```

Result:

```text
Validated Kubernetes manifests: 17
```

### Kustomize render check

```bash
if command -v kustomize >/dev/null 2>&1; then kustomize build kubernetes/base >/tmp/f4-platform-correlation-observability-render.yaml && echo "kustomize build passed"; elif command -v kubectl >/dev/null 2>&1; then kubectl kustomize kubernetes/base >/tmp/f4-platform-correlation-observability-render.yaml && echo "kubectl kustomize passed"; else echo "SKIPPED: neither kustomize nor kubectl is available"; fi
```

Result:

```text
SKIPPED: neither kustomize nor kubectl is available
```

### Terraform validation

Not applicable. No Terraform files were changed for this task.

### Archive and spec validation

```bash
npx --yes @fission-ai/openspec validate f4-platform-correlation-observability --strict && npx --yes @fission-ai/openspec archive f4-platform-correlation-observability --yes && npx --yes @fission-ai/openspec validate --specs --strict
```

Result:

```text
Change 'f4-platform-correlation-observability' is valid
Task status: ✓ Complete

Specs to update:
  platform-correlation-observability: create
  platform-service-deployments: update
Applying changes to openspec/specs/platform-correlation-observability/spec.md:
  + 5 added
Applying changes to openspec/specs/platform-service-deployments/spec.md:
  ~ 1 modified
Totals: + 5, ~ 1, - 0, → 0
Specs updated successfully.
Change 'f4-platform-correlation-observability' archived as '2026-07-19-f4-platform-correlation-observability'.
- Validating...
✓ spec/platform-correlation-observability
✓ spec/platform-rabbitmq
✓ spec/platform-service-deployments
Totals: 3 passed, 0 failed (3 items)
```

## Implemented Conventions

- Shared ConfigMap: `correlation-observability-config`
- Namespace: `stag`
- HTTP header: `X-Correlation-Id`
- RabbitMQ message header/property key: `correlationId`
- Structured log field: `correlationId`
- Metrics label: `correlation_id`
- Deployment/Pod label: `observability.workshop.io/correlation-id: enabled`

Application repositories remain responsible for creating, propagating, logging, and emitting correlation IDs.
