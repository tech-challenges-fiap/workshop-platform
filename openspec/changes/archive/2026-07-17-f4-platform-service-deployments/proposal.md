## Why

Phase 4 splits the workshop application into independently deployable Order Service (OS), Billing Service, and Execution Service workloads. The platform repository must provide Kubernetes deployment wiring that defines the shared baseline for those services without implementing service code, business behavior, or observability correlation.

## What Changes

- Add Kubernetes base manifests for `order-service`, `billing-service`, and `execution-service` as independent Deployments and ClusterIP Services.
- Add per-service ConfigMaps with stable platform/environment settings and RabbitMQ service discovery values.
- Wire the new manifests into `kubernetes/base/kustomization.yaml` following the existing base resource convention.
- Update Kubernetes manifest validation so the service deployment directories are treated as required platform baseline paths.
- Document the service deployment topology, placeholder image contract, internal DNS names, and ownership boundaries.

## Capabilities

### New Capabilities

- `platform-service-deployments`: Kubernetes platform baseline for OS, Billing, and Execution service Deployments, Services, and runtime configuration placeholders.

### Modified Capabilities

- None.

## Impact

- Application repositories receive stable names, selectors, ports, and placeholder image fields to patch during environment-specific release workflows.
- No Terraform changes are required; the manifests target the existing `stag` namespace baseline and rely on the existing cluster and namespace resources.
- No application code, message handlers, database wiring, ingress routing, or correlation observability is introduced by this change.
