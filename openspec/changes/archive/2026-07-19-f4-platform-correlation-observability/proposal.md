## Why

Phase 4 services need a shared platform convention for carrying and exposing `correlationId` across HTTP calls, RabbitMQ messages, logs, metrics, and Kubernetes metadata. The platform repository owns baseline manifests and documentation, so it must provide consistent configuration placeholders and labels/annotations without implementing application instrumentation or claiming a centralized observability stack exists.

## What Changes

- Add a shared Kubernetes ConfigMap with platform-level correlation observability conventions for OS, Billing, and Execution workloads.
- Add common labels and annotations to Phase 4 service Deployments and Pod templates so log/metric collectors can discover service role, phase, and correlation support intent.
- Wire service Deployments to consume the shared correlation ConfigMap alongside their service-specific ConfigMaps.
- Add manifest validation coverage for the shared observability manifest path.
- Document the topology, propagation conventions, supported environment variables, and ownership boundaries without adding app code, database resources, ingress, dashboards, or a live centralized tracing/logging stack.

## Capabilities

### New Capabilities

- `platform-correlation-observability`: platform-level correlation observability conventions and Kubernetes configuration placeholders for Phase 4 services.

### Modified Capabilities

- `platform-service-deployments`: service Deployments consume the shared correlation observability ConfigMap and expose common metadata.

## Impact

- Application teams receive stable environment variables and metadata conventions for implementing correlation propagation consistently.
- Platform validation covers the new observability convention manifest.
- No Terraform changes are required.
- No application code, Datadog dashboards, tracing agents, database resources, ingress rules, or live centralized observability stack is introduced by this change.
