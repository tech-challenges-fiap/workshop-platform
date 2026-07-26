## Context

`f4-platform-correlation-observability` (archived
2026-07-19) established platform-level naming conventions for `correlationId`
propagation (HTTP header, RabbitMQ message key, log field, metrics label) via
a Kubernetes ConfigMap, but explicitly did not add "app code, database
resources, ingress resources, dashboards, alert rules, collectors,
OpenTelemetry Collector resources, or Datadog runtime configuration."

Fase 4 closure plan gap #6 asks this repository to close that gap minimally:
stand up a local, zero-cost OTel Collector and capture evidence that a
correlation identifier is observable end-to-end, without touching Datadog or
any real AWS resource, and while explicitly deferring the full three-service
`kind` cross-service capture to gap #2 (Kubernetes parity), which is a
separate human task.

## Goals / Non-Goals

**Goals:**

- Provide a runnable, local-only OpenTelemetry Collector via Docker Compose
  that any contributor can start with one command.
- Configure the collector with an `otlp` receiver (gRPC + HTTP) and a
  `debug` exporter (`verbosity: detailed`) so received telemetry — including
  a `correlationId` attribute — is visible in the collector's own logs.
- Bind the collector's published ports to loopback (`127.0.0.1`) only, since
  this is local developer/evidence tooling and must not accept telemetry
  from other hosts on the network.
- Document a synthetic smoke test (a made-up OTLP payload posted via `curl`)
  that proves the collector pipeline itself works, and capture the
  resulting log evidence in the existing correlation-observability evidence
  doc.
- Give a human a copy-pasteable, accurate set of commands to run once gap
  #2's `kind` cluster and real service manifests exist, to capture full
  cross-service `correlationId` evidence — using the real Deployment names
  that exist in this repository today (`order-service`, `billing-service`,
  `execution-service`), not application-repo-only names like `workshop-app`.

**Non-Goals:**

- Deploy the collector inside any Kubernetes cluster (`kind` or otherwise)
  as part of this change — that remains a documented, pending human step.
- Add a Datadog exporter or any AWS-backed telemetry backend.
- Change application code in `workshop-app`, `workshop-billing`, or
  `workshop-execution`.
- Claim that full cross-service correlation-id propagation has been
  observed; only the collector pipeline itself is verified here.

## Decisions

### Local-only Docker Compose file, not a Kubernetes manifest

`docker-compose.otel.yml` lives at the repository root, separate from
`kubernetes/base/`. It is not referenced by
`kubernetes/base/kustomization.yaml` and is not applied to any cluster. This
keeps the platform's Kubernetes baseline (owned by
`platform-service-deployments` / `platform-correlation-observability`)
unchanged while still giving contributors a way to exercise a real
collector locally.

### Loopback-only port binding

The Compose file publishes the collector's OTLP ports as `127.0.0.1:4317:4317`
and `127.0.0.1:4318:4318` rather than bare `4317:4317` / `4318:4318`. Bare
short-form port mappings publish on all host network interfaces by default,
which would let other hosts on the same network submit arbitrary OTLP data
to a collector that only logs (does not authenticate) inbound telemetry.
Since this tool is local-only by design, binding explicitly to loopback
closes that exposure without reducing usefulness for local testing.

### `debug` exporter instead of `logging`

`opentelemetry-collector-contrib` renamed the `logging` exporter to `debug`
around v0.95. This change uses `otel/opentelemetry-collector-contrib:0.111.0`
and the `debug` exporter with `verbosity: detailed`, which is the direct,
currently-supported equivalent of the older `logging` exporter's most
verbose mode.

### Evidence lives as an addendum, not a new competing file

The synthetic smoke test evidence and the pending-human-steps runbook are
appended to the existing
`docs/evidence/fase-4/f4-platform-correlation-observability.md` file rather
than a new evidence file, because that file already documents the exact gap
this change closes (it explicitly lists collectors and OpenTelemetry
Collector resources as out of scope for the earlier change). The
addendum corrects an earlier draft's reference to a `workshop-app`
Deployment — this repository's actual OS Kubernetes Deployment is named
`order-service` (see `kubernetes/base/services/order-service/deployment.yaml`
and `docs/architecture.md`).

## Risks / Trade-offs

- **Collector is not integrated with any cluster**: this change proves the
  collector configuration works in isolation; it does not prove real
  service instrumentation reaches it. That gap is explicitly documented as
  a pending human step.
- **Loopback binding limits use to the local machine running Compose**:
  acceptable, since the stated scope is local-only, zero-cost evidence.
- **Image pin (`0.111.0`) will eventually go stale**: acceptable for a
  local evidence tool; a future change can bump it if needed.

## Migration Plan

1. Add `docker-compose.otel.yml` and
   `observability/otel-collector/otel-collector-config.yaml`.
2. Validate the Compose file (`docker compose -f docker-compose.otel.yml
   config`).
3. Run a synthetic OTLP smoke test locally, capture the log evidence.
4. Tear down the Compose stack (no containers left running).
5. Update `docs/evidence/fase-4/f4-platform-correlation-observability.md`
   with the addendum (evidence + pending human steps using correct
   Deployment names) and `docs/development.md` with a pointer.
6. Validate this OpenSpec change and reference it in the PR.
7. After merge to `stag`, archive the change.

## Open Questions

- Should a follow-up change add an actual in-cluster Deployment/Service for
  the collector once gap #2's `kind` cluster exists? **Deferred** to the
  human task documented in the evidence addendum.
