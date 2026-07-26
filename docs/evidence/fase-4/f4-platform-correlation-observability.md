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

## Addendum (2026-07-26): Local OTel Collector Evidence — Fase 4 Closure Gap #6

**Scope:** Fase 4 closure plan gap #6 (lowest priority, minimal scope). This
addendum closes the gap flagged by `OBSERVABILITY_STACK_STATUS:
convention-only` above: it stands up a real, local, zero-cost OTel Collector
so a correlation id can be *observed* flowing across services, without
touching Datadog or any AWS resource. It intentionally does not change any
Kubernetes manifest, Terraform resource, or application code.

### What was added

- `docker-compose.otel.yml` (repo root) — a standalone Docker Compose file
  that runs a single `otel/opentelemetry-collector-contrib:0.111.0`
  container, exposing the standard OTLP ports:
  - `4317` (OTLP gRPC)
  - `4318` (OTLP HTTP)
- `observability/otel-collector/otel-collector-config.yaml` — the collector
  pipeline: `otlp` receiver (grpc + http) -> `debug` exporter (the current
  name for the former `logging` exporter) for `traces`, `logs`, and
  `metrics`. `verbosity: detailed` so every attribute, including
  `correlationId`, is printed to the container's stdout.

This is local developer/evidence tooling only. It is not referenced by
`kubernetes/base/kustomization.yaml`, is not applied to the `kind` cluster
by default, and does not require or configure `enable_datadog`.

### Why `debug` and not `logging`

The task and repo conventions refer to a "logging exporter." In
`opentelemetry-collector-contrib` releases from roughly 0.95 onward, that
exporter was renamed `debug` (same behavior: prints received telemetry to
stdout with configurable verbosity). `otel-collector-config.yaml` uses
`debug` with `verbosity: detailed` to get the equivalent of the old
`logging` exporter's most verbose mode.

### Local synthetic smoke test performed (evidence)

Since `kind` is not installed in this environment and standing up the full
3-service `kind` cluster is an explicit human task (gap #2), this addendum
only proves the collector configuration itself is correct: it accepts OTLP
and prints the same identifiers across independent resource spans, which is
exactly what will be needed once real services point at it.

Commands run:

```bash
docker compose -f docker-compose.otel.yml config   # validate compose file
docker compose -f docker-compose.otel.yml up -d    # start collector only
curl -sS -X POST "http://localhost:4318/v1/traces" \
  -H "Content-Type: application/json" \
  --data @otlp-traces-payload.json \
  -w "\nHTTP_STATUS=%{http_code}\n"
docker compose -f docker-compose.otel.yml logs otel-collector
docker compose -f docker-compose.otel.yml down     # tear down, no leftover containers
```

The synthetic payload contained three `resourceSpans` entries — one each
tagged `service.name = workshop-app`, `workshop-billing`, and
`workshop-execution` — all sharing one OTel trace id and one made-up
`correlationId` attribute (`f4-gap6-smoke-test-correlation-id-0001`), to
simulate a request flowing OS -> Billing -> Execution.

`curl` result: `{"partialSuccess":{}}` with `HTTP_STATUS=200`.

Collector log excerpt (trimmed, one span per service; full run showed
`"resource spans": 3, "spans": 3"`):

```text
ResourceSpans #0
Resource attributes:
     -> service.name: Str(workshop-app)
Span #0
    Trace ID       : 5b8aa5a2d2c872e8321cf37308d69df2
    Name           : POST /work-orders
Attributes:
     -> correlationId: Str(f4-gap6-smoke-test-correlation-id-0001)

ResourceSpans #1
Resource attributes:
     -> service.name: Str(workshop-billing)
Span #0
    Trace ID       : 5b8aa5a2d2c872e8321cf37308d69df2
    Parent ID      : 051581bf3cb55c13
    Name           : billing.charge
Attributes:
     -> correlationId: Str(f4-gap6-smoke-test-correlation-id-0001)

ResourceSpans #2
Resource attributes:
     -> service.name: Str(workshop-execution)
Span #0
    Trace ID       : 5b8aa5a2d2c872e8321cf37308d69df2
    Parent ID      : 6c2af9a5e3b1d444
    Name           : execution.schedule
Attributes:
     -> correlationId: Str(f4-gap6-smoke-test-correlation-id-0001)
```

The same OTel trace id (`5b8aa5a2d2c872e8321cf37308d69df2`) and the same
`correlationId` (`f4-gap6-smoke-test-correlation-id-0001`) appear across all
three simulated services, with parent/child span linkage matching the
OS -> Billing -> Execution call order. This proves the collector pipeline
config is correct end-to-end for the receive -> export path. It does **not**
prove real cross-service instrumentation — that requires the actual services
running and exporting OTLP, which is the pending human step below.

The compose stack was stopped and removed after the smoke test
(`docker compose -f docker-compose.otel.yml down`); no containers were left
running.

### Pending human validation step (once gap #2 / `kind` lands)

Full cross-service correlation-id evidence (OS -> Billing -> Execution
inside the actual `kind` cluster) is **not** captured by this addendum and
remains a pending human task, to be run once:

1. Gap #2 (Kubernetes parity) has produced a real `kind` cluster
   (`workshop-f4-k8s` or equivalent) with `workshop-app`, `workshop-billing`,
   and `workshop-execution` all deployed with real (non-placeholder) images
   and reaching `Ready` — see `workshop-app`'s
   `docs/fase-4/kubernetes-evidence.md` for the baseline cluster evidence
   this builds on.
2. Each service's `OTEL_EXPORTER_OTLP_ENDPOINT` points at a collector
   reachable from inside the cluster.

Copy-pasteable commands for a human to run at that point:

```bash
# 1. Deploy this collector inside the kind cluster instead of via
#    docker-compose (docker-compose is for the local-only smoke test above).
#    Reuse the same pipeline from observability/otel-collector/otel-collector-config.yaml
#    as a ConfigMap, e.g.:
kubectl create configmap otel-collector-config \
  -n stag \
  --from-file=otel-collector-config.yaml=observability/otel-collector/otel-collector-config.yaml

# Then apply a minimal Deployment + ClusterIP Service for
# otel/opentelemetry-collector-contrib:0.111.0 in the stag namespace,
# mounting that ConfigMap at /etc/otel-collector-config.yaml and exposing
# 4317/4318 (this Deployment/Service is not included in this PR — it is the
# human's task once gap #2's cluster exists, to avoid speculative Kubernetes
# resources ahead of that work).

# 2. Point each service's OTEL_EXPORTER_OTLP_ENDPOINT at the in-cluster
#    collector Service, e.g.:
#    OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.stag.svc.cluster.local:4318

# 3. Drive one real request through the system, e.g. create a work order via
#    workshop-app's public endpoint so it fans out to Billing and Execution.
curl -fsS -X POST "http://<workshop-app-ingress-or-portforward>/work-orders" \
  -H "Content-Type: application/json" \
  -d '{"...": "..."}'

# 4. Tail the collector logs and grep for the correlationId that shows up in
#    the Order Service (OS / workshop-app)'s own structured logs for that
#    request:
kubectl logs -n stag deployment/otel-collector -f | grep -i correlationId

# 5. Cross-check the same correlationId (or X-Correlation-Id header value)
#    appears in each service's own structured logs. Use the Deployment names
#    defined in this repository's kubernetes/base/services/*/deployment.yaml
#    (order-service is the OS Deployment name here; the workshop-app repo's
#    own overlay may deploy the same workload under a different Deployment
#    name such as "workshop-app" if it is applied instead of/alongside the
#    platform placeholder — check `kubectl get deploy -n stag` and use the
#    name that is actually running):
kubectl logs -n stag deployment/order-service      | grep -i correlationId
kubectl logs -n stag deployment/billing-service    | grep -i correlationId
kubectl logs -n stag deployment/execution-service  | grep -i correlationId

# 6. Record the trace id + correlationId pair and the matching log lines as
#    the final cross-service evidence, then tear down any disposable
#    resources created only for the evidence run.
```

### OpenSpec governance

This addendum's runnable artifacts (`docker-compose.otel.yml`,
`observability/otel-collector/otel-collector-config.yaml`) are governed by
the OpenSpec change `f4-platform-otel-collector-evidence` under
`openspec/changes/f4-platform-otel-collector-evidence/`, validated with:

```bash
npx --yes @fission-ai/openspec validate f4-platform-otel-collector-evidence --strict
```

The change is archived after this PR merges to `stag`, per this
repository's standard OpenSpec workflow.
