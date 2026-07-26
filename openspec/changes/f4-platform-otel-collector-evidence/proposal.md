## Why

Fase 4 closure plan gap #6 (lowest priority, minimal scope) asks for local,
zero-cost evidence that a `correlationId` (or equivalent trace identifier)
can be observed consistently across OTLP telemetry, as a stepping stone
toward the full three-service `kind` cross-service capture that depends on
gap #2 (Kubernetes parity). Implementing this requires a runnable local
OpenTelemetry Collector (Docker Compose service + collector config), not
just a documentation edit, so it falls under this repository's OpenSpec
governance rather than the doc-only exemption.

## What Changes

- Add `docker-compose.otel.yml` at the repository root: a standalone, local-only
  Docker Compose service running `otel/opentelemetry-collector-contrib`, with
  its OTLP gRPC (`4317`) and OTLP HTTP (`4318`) ports bound to `127.0.0.1`
  only (loopback), so no other host on the network can submit telemetry to it.
- Add `observability/otel-collector/otel-collector-config.yaml`: the collector
  pipeline (`otlp` receiver -> `debug` exporter, the current name for the
  former `logging` exporter) for `traces`, `logs`, and `metrics`, with
  `verbosity: detailed`.
- Add an addendum section to
  `docs/evidence/fase-4/f4-platform-correlation-observability.md`
  documenting the synthetic OTLP smoke test performed (payload shape, `curl`
  command, collector log excerpt showing the same OTel trace id and the same
  made-up `correlationId` across three simulated `resourceSpans` tagged
  `workshop-app`, `workshop-billing`, `workshop-execution`) and the exact
  pending human steps/commands to capture full cross-service evidence once
  gap #2's `kind` cluster and manifests exist. Correct that addendum's
  copy-pasteable command to reference the real Kubernetes Deployment name
  `order-service` (not `workshop-app`), matching
  `kubernetes/base/services/order-service/deployment.yaml`.
- Add a short pointer to the new local tool in `docs/development.md`.

## Capabilities

### New Capabilities

- `platform-otel-collector-evidence`: local, zero-cost OpenTelemetry
  Collector tooling and evidence conventions for capturing correlation-id
  propagation during Phase 4 manual/local testing. This is distinct from
  `platform-correlation-observability` (which defines Kubernetes ConfigMap
  naming conventions only) because it adds a runnable local collector and
  documented smoke-test evidence.

## Impact

- No Terraform changes; no AWS resources; no cost.
- No Datadog changes.
- No Kubernetes manifests changed. This tooling is not wired into
  `kubernetes/base/kustomization.yaml` and does not run inside any cluster
  by default; it is a local developer/evidence tool only.
- Adds a new local developer/evidence tool at the repository root plus
  supporting documentation.
- Full cross-service `kind`-based correlation-id evidence (OS -> Billing ->
  Execution running real service images inside a real cluster) remains a
  separate, explicitly documented pending human validation task tied to gap
  #2 and is not claimed as complete by this change.
