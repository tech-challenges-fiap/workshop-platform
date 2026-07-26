## 1. OpenSpec

- [x] 1.1 Create proposal, design, tasks, and spec deltas for
      `platform-otel-collector-evidence`.
- [x] 1.2 Validate the change with
      `npx --yes @fission-ai/openspec validate f4-platform-otel-collector-evidence --strict`.

## 2. Local OTel Collector Tooling

- [x] 2.1 Add `docker-compose.otel.yml` at the repository root running
      `otel/opentelemetry-collector-contrib:0.111.0` with OTLP gRPC (`4317`)
      and OTLP HTTP (`4318`) receivers.
- [x] 2.2 Bind both published ports to `127.0.0.1` only (loopback), not all
      host interfaces.
- [x] 2.3 Add `observability/otel-collector/otel-collector-config.yaml` with
      an `otlp` receiver and a `debug` exporter (`verbosity: detailed`) wired
      into `traces`, `logs`, and `metrics` pipelines.
- [x] 2.4 Keep this tooling out of `kubernetes/base/kustomization.yaml` and
      out of Terraform; it must not run inside any cluster or touch AWS by
      default.

## 3. Validation

- [x] 3.1 Run `docker compose -f docker-compose.otel.yml config` and confirm
      it renders without error.
- [x] 3.2 Run `terraform fmt -check -recursive`, `terraform init
      -backend=false`, `terraform validate` and confirm they still pass
      (unaffected, since no Terraform files changed).
- [x] 3.3 Run `./scripts/validate-k8s-manifests.sh` and confirm it still
      reports the same manifest count (unaffected, since no `kubernetes/`
      files changed).

## 4. Synthetic Smoke Test Evidence

- [x] 4.1 Start only the collector
      (`docker compose -f docker-compose.otel.yml up -d`); do not attempt to
      start a `kind` cluster or the three application services (out of
      scope / no `kind` binary available in this environment).
- [x] 4.2 POST a synthetic OTLP trace payload (three `resourceSpans` tagged
      `workshop-app`, `workshop-billing`, `workshop-execution`, sharing one
      trace id and one made-up `correlationId`) to the collector's OTLP HTTP
      endpoint via `curl`.
- [x] 4.3 Capture the collector log excerpt showing the same trace id and
      the same `correlationId` across all three simulated services.
- [x] 4.4 Tear the stack down (`docker compose -f docker-compose.otel.yml
      down`); confirm no containers are left running.

## 5. Documentation

- [x] 5.1 Add an addendum section to
      `docs/evidence/fase-4/f4-platform-correlation-observability.md`
      documenting what was added, the smoke test commands/output, and the
      pending human steps (with copy-pasteable commands using the real
      `order-service` Deployment name) to capture full cross-service
      evidence once gap #2's `kind` cluster exists.
- [x] 5.2 Fix the addendum's `kubectl logs` example to reference
      `deployment/order-service` instead of the incorrect
      `deployment/workshop-app`, and check for other similarly wrong
      references in the same section.
- [x] 5.3 Add a short pointer to the new local tool in
      `docs/development.md`.

## 6. Final Validation and Evidence

- [x] 6.1 Re-run strict OpenSpec validation for this change.
- [x] 6.2 Re-run `docker compose -f docker-compose.otel.yml config` after
      the loopback-binding fix and confirm it still validates.
- [x] 6.3 Re-run Terraform validation and
      `./scripts/validate-k8s-manifests.sh`; confirm both still pass.
