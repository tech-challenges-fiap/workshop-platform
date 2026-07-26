## Context

Phase 4 requires the Order Service (OS), Billing Service, and Execution Service to be deployable and addressable as separate Kubernetes services. `workshop-platform` owns shared Kubernetes baseline manifests and validation conventions, while application repositories own runtime implementation, image build/release, handler behavior, database access, and observability instrumentation.

The current Kubernetes base defines shared namespaces and the RabbitMQ broker baseline. It does not yet define service-level Deployment or Service resources for the three Phase 4 application services.

Constraints:
- Keep this repository focused on platform deployment manifests and wiring.
- Do not introduce application service code or business logic.
- Do not implement correlation observability; that is tracked separately.
- Do not claim production-ready images exist in this repository. Images remain placeholders that downstream delivery workflows must patch.
- Continue to use the current `kubernetes/base/` Kustomize convention.

## Goals / Non-Goals

**Goals:**

- Define independent Kubernetes Deployments for `order-service`, `billing-service`, and `execution-service`.
- Define internal ClusterIP Services with stable DNS names for each workload.
- Define per-service ConfigMaps for stable platform-level settings such as service role, environment, peer service URLs, and RabbitMQ hostname/port.
- Wire all service manifests into the base Kustomization.
- Extend validation coverage and document the topology and placeholder ownership contract.

**Non-Goals:**

- Implement application code, containers, handlers, queue topology, or Saga behavior.
- Add public ingress, edge routing, database provisioning, or secrets for service-specific credentials.
- Add Datadog traces, correlation IDs, dashboards, or alert rules.
- Add Terraform resources.
- Define production image tags; image references are explicit placeholders.

## Decisions

### One Deployment and one Service per microservice

Each Phase 4 service gets its own Deployment and ClusterIP Service so it can be scaled, rolled out, and discovered independently. Shared labels use `app.kubernetes.io/name`, `app.kubernetes.io/component`, `app.kubernetes.io/part-of`, and `app.kubernetes.io/managed-by` so future overlays and tooling can select each service reliably.

### Initial target namespace: `stag`

The base manifests set `metadata.namespace: stag` because this repository currently exposes `stag` and `prod` as fixed runtime namespaces and Phase 4 validation work lands through `stag`. Production promotion can reuse the same manifests with namespace/image patches in a future overlay or delivery workflow; this change does not introduce a new overlay structure.

### Placeholder images instead of app implementation

Deployment containers use `example.invalid/workshop/<service>:replace-me` image names. This keeps the Kubernetes object shape renderable while making it clear that the platform does not provide service binaries. Release automation or application repos must replace these image values before applying to a live cluster.

### Internal-only Services

Services are `ClusterIP` on port 80 targeting container port 8080. This exposes stable in-cluster DNS names such as `order-service.stag.svc.cluster.local` without making the workloads public. Public edge routing remains outside this change.

## Risks / Trade-offs

- **Placeholder images are not runnable as-is**: applying the base directly would create Pods that fail to pull images. This is intentional and documented; downstream release workflows must patch images.
- **No production overlay**: the manifests target `stag` initially to match the current platform flow. A future change can add overlays when the repository has an agreed convention.
- **ConfigMap values are platform defaults**: application repos may need to override variables as service contracts mature.

## Migration Plan

1. Add service baseline manifests and Kustomize wiring.
2. Validate OpenSpec and Kubernetes rendering locally.
3. Application delivery workflows patch image names/tags and, when needed, namespace/environment values before applying.

## Open Questions

- Should `prod` overlays live in this repository or in application delivery repositories? **Deferred** until deployment workflow ownership is finalized.
- Should service-specific Secret templates be standardized here? **Deferred** because database/API credentials are outside platform scope.
