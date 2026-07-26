## ADDED Requirements

### Requirement: Local OpenTelemetry Collector tooling

The platform SHALL provide a standalone, local-only Docker Compose
definition that runs an OpenTelemetry Collector for Phase 4 correlation-id
evidence capture, without provisioning any AWS resource or Datadog
component.

#### Scenario: Collector Compose file validates

- **WHEN** `docker compose -f docker-compose.otel.yml config` is run
- **THEN** it SHALL render without error
- **AND** it SHALL define exactly one service named `otel-collector` using
  an `otel/opentelemetry-collector-contrib` image

#### Scenario: Collector is not wired into the Kubernetes baseline

- **WHEN** `kubernetes/base/kustomization.yaml` is inspected
- **THEN** it SHALL NOT reference `docker-compose.otel.yml` or the
  collector image
- **AND** the collector SHALL NOT run automatically as part of any
  Terraform apply or Kubernetes deploy workflow

### Requirement: Loopback-only OTLP port binding

The local OTel Collector's published OTLP ports SHALL be bound to the
loopback interface only, so telemetry cannot be submitted from other hosts
on the network.

#### Scenario: Ports are bound to 127.0.0.1

- **WHEN** `docker-compose.otel.yml` is inspected
- **THEN** the OTLP gRPC port mapping SHALL be `127.0.0.1:4317:4317`
- **AND** the OTLP HTTP port mapping SHALL be `127.0.0.1:4318:4318`
- **AND** neither port mapping SHALL use a bare host port (e.g. `4317:4317`)
  that publishes on all host interfaces

### Requirement: Synthetic smoke test evidence

Platform evidence documentation SHALL record a synthetic OTLP smoke test
proving the collector pipeline receives and exports telemetry carrying a
`correlationId` attribute consistently across simulated services.

#### Scenario: Evidence records a shared identifier across services

- **WHEN** a developer reads
  `docs/evidence/fase-4/f4-platform-correlation-observability.md`
- **THEN** they SHALL find a synthetic OTLP payload description with
  `resourceSpans` tagged for `workshop-app`, `workshop-billing`, and
  `workshop-execution`
- **AND** they SHALL find a collector log excerpt showing the same OTel
  trace id and the same `correlationId` value across all three simulated
  services
- **AND** they SHALL find confirmation that the Compose stack was torn down
  after the test with no containers left running

### Requirement: Accurate pending human-step commands

Platform evidence documentation SHALL give a human accurate, copy-pasteable
commands to capture full cross-service `correlationId` evidence once gap #2
(Kubernetes parity / `kind`) lands, referencing this repository's actual
Kubernetes Deployment names.

#### Scenario: Documented commands use real Deployment names

- **WHEN** a developer reads the pending-human-step commands in
  `docs/evidence/fase-4/f4-platform-correlation-observability.md`
- **THEN** the Order Service log command SHALL reference
  `deployment/order-service`, matching
  `kubernetes/base/services/order-service/deployment.yaml`
- **AND** it SHALL NOT reference a Deployment name that does not exist in
  this repository's Kubernetes manifests (e.g. `workshop-app`)

#### Scenario: Documentation states the pending step is not yet complete

- **WHEN** a developer reads the addendum
- **THEN** they SHALL find an explicit statement that full cross-service
  `correlationId` evidence inside a real `kind` cluster is a pending human
  validation step, not claimed as complete by this change
