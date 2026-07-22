# platform-correlation-observability Specification

## Purpose
TBD - created by archiving change f4-platform-correlation-observability. Update Purpose after archive.
## Requirements
### Requirement: Shared correlation observability configuration

The platform SHALL define a shared Kubernetes ConfigMap for Phase 4 services that names the target-state correlation ID propagation and telemetry fields without implementing application behavior.

#### Scenario: Shared ConfigMap renders

- **WHEN** the Kustomize base is rendered
- **THEN** it SHALL include a ConfigMap named `correlation-observability-config` in the `stag` namespace
- **AND** the ConfigMap SHALL include `CORRELATION_ID_HTTP_HEADER`, `CORRELATION_ID_MESSAGE_HEADER`, `CORRELATION_ID_LOG_FIELD`, and `CORRELATION_ID_METRICS_LABEL`

#### Scenario: Correlation names are stable

- **WHEN** a developer inspects `correlation-observability-config`
- **THEN** `CORRELATION_ID_HTTP_HEADER` SHALL be `X-Correlation-Id`
- **AND** `CORRELATION_ID_MESSAGE_HEADER` SHALL be `correlationId`
- **AND** `CORRELATION_ID_LOG_FIELD` SHALL be `correlationId`
- **AND** `CORRELATION_ID_METRICS_LABEL` SHALL be `correlation_id`

### Requirement: Phase 4 services consume correlation conventions

The platform SHALL attach the shared correlation observability ConfigMap to OS, Billing, and Execution Deployments as runtime configuration while preserving each service's existing ConfigMap.

#### Scenario: Deployments import shared correlation config

- **WHEN** a Phase 4 service Deployment pod template is inspected
- **THEN** the application container SHALL import its service-specific ConfigMap using `envFrom.configMapRef`
- **AND** it SHALL import `correlation-observability-config` using `envFrom.configMapRef`

#### Scenario: Service-specific config remains intact

- **WHEN** the service ConfigMaps are inspected
- **THEN** `order-service-config`, `billing-service-config`, and `execution-service-config` SHALL remain present and continue to provide platform service wiring defaults

### Requirement: Correlation observability metadata

The platform SHALL label and annotate Phase 4 service Deployments and Pod templates with common correlation observability metadata so future log/metric/trace tooling can discover the target-state convention.

#### Scenario: Workload metadata advertises correlation support

- **WHEN** OS, Billing, and Execution Deployment metadata is inspected
- **THEN** each Deployment SHALL include `observability.workshop.io/correlation-id: enabled`
- **AND** each Deployment SHALL include annotations naming the expected HTTP header, message header, log field, and metrics label

#### Scenario: Pod template metadata advertises correlation support

- **WHEN** OS, Billing, and Execution Pod template metadata is inspected
- **THEN** each Pod template SHALL include `observability.workshop.io/correlation-id: enabled`
- **AND** each Pod template SHALL include annotations naming the expected HTTP header, message header, log field, and metrics label

### Requirement: Kustomize and validation coverage for observability conventions

The platform SHALL wire correlation observability manifests into the Kubernetes base and validation script.

#### Scenario: Base includes observability manifest

- **WHEN** `kustomize build kubernetes/base` or `kubectl kustomize kubernetes/base` is run
- **THEN** the rendered output SHALL include `correlation-observability-config`

#### Scenario: Validation script requires observability directory

- **WHEN** `./scripts/validate-k8s-manifests.sh` is run
- **THEN** it SHALL require and validate `kubernetes/base/observability`

### Requirement: Accurate correlation observability documentation

Platform documentation SHALL explain correlation ID conventions and boundaries without claiming that this repository implements app instrumentation or a live centralized observability stack.

#### Scenario: Developer finds the platform convention

- **WHEN** a developer reads platform documentation
- **THEN** they SHALL find the HTTP header, message header, structured log field, metrics label, shared ConfigMap name, and metadata conventions
- **AND** they SHALL find that application repositories must implement ID creation, propagation, logging, and metrics emission
- **AND** they SHALL find that centralized logs, traces, dashboards, and collectors are not introduced by this change

