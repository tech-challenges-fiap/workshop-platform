## Context

Phase 4 separates the workshop runtime into Order Service (OS), Billing Service, and Execution Service. Previous platform changes established RabbitMQ as the shared broker and added baseline Kubernetes Deployments/Services for those workloads. The next platform step is to make correlation observability expectations explicit at the platform level so application repositories can implement consistent propagation and telemetry.

The platform repository can provide Kubernetes metadata and configuration placeholders, but it does not own runtime code, instrumentation libraries, log serialization, message handlers, dashboards, or Datadog/tracing agent deployment beyond the existing optional Datadog Terraform flag.

## Goals / Non-Goals

**Goals:**

- Define a shared ConfigMap with environment variables that name the expected correlation ID header, message metadata key, log field, and metrics label.
- Attach the shared ConfigMap to OS, Billing, and Execution Deployments through `envFrom`.
- Add labels/annotations that make Phase 4 services discoverable as correlation-aware target-state workloads.
- Document how `correlationId` should be exposed across HTTP, RabbitMQ, logs, and metrics without claiming the platform currently aggregates those signals.
- Extend manifest validation and Kustomize wiring for the new observability manifest path.

**Non-Goals:**

- Implement application code, middleware, HTTP filters, RabbitMQ publishers/consumers, logging formatters, or metrics emitters.
- Add database resources, ingress resources, public endpoints, dashboards, alert rules, collectors, tracing sidecars, OpenTelemetry Collector, or Datadog runtime configuration.
- Claim that centralized logs, traces, metrics, or dashboards are live unless separately enabled by existing platform mechanisms.
- Change Terraform.

## Decisions

### Shared ConfigMap for correlation conventions

A single ConfigMap named `correlation-observability-config` in the `stag` namespace contains platform-wide naming conventions. Each service Deployment imports it with `envFrom.configMapRef`, in addition to the existing service-specific ConfigMap. This keeps service configuration local while avoiding divergent correlation naming.

### Stable names

The target-state convention uses:

- HTTP header: `X-Correlation-Id`
- RabbitMQ message header/property key: `correlationId`
- Structured log field: `correlationId`
- Metrics label: `correlation_id`

The ConfigMap stores names only. It does not create the ID, enforce propagation, or emit telemetry.

### Metadata instead of observability stack resources

Deployments and Pod templates receive common labels such as `observability.workshop.io/correlation-id: enabled` and annotations describing expected fields. Collectors or dashboards can use these later, but this change does not add those collectors or dashboards.

### Initial namespace remains `stag`

The existing service baseline targets the `stag` namespace. The observability ConfigMap follows the same target. Production can reuse the same contract through a future overlay or delivery-time patching.

## Risks / Trade-offs

- **Configuration is advisory until app code implements it**: services must still create, propagate, and log correlation IDs in their own repositories.
- **No centralized stack claim**: logs/metrics/traces may not be aggregated unless optional Datadog or another stack is enabled elsewhere.
- **Single namespace baseline**: `prod` support depends on future overlays or deployment-time namespace patches, matching the current service deployment baseline.

## Migration Plan

1. Add the shared correlation observability ConfigMap and Kustomize wiring.
2. Update existing service Deployments to consume the ConfigMap and expose common metadata.
3. Update validation and documentation.
4. Application repositories implement middleware/message handling/logging/metrics using the documented variables.

## Open Questions

- Which application repository owns concrete middleware and message propagation implementation? **Deferred** to service/application owners.
- Should a future change add OpenTelemetry Collector or Datadog-specific dashboards? **Deferred** until a centralized observability stack is explicitly in scope.
