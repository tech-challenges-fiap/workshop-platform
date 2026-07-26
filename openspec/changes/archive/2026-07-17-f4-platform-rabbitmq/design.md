## Context

Phase 4 requires async event-driven communication between the Order, Billing, and Execution microservices. The platform team owns the shared EKS cluster; application repos deploy their workloads into the `stag` and `prod` namespaces but do not own cluster-level infrastructure. A single shared RabbitMQ broker, managed by `workshop-platform`, satisfies the messaging requirement without requiring each application repo to run its own broker.

The current `kubernetes/base/` layer defines only namespace resources. No message broker exists in the cluster today.

Constraints:
- No new Terraform resources are needed: the broker runs as in-cluster Kubernetes workloads using existing cluster capacity.
- The default EKS node is `t3.small`; the broker must fit in that profile (single-replica for cost, not HA).
- `stag` and `prod` are namespaces in the same cluster. The broker is deployed once in a shared namespace (`rabbitmq`) and reached by workloads in both namespaces through internal DNS.
- Credentials must be stored as a Kubernetes Secret so application repos can reference them without encoding secrets in manifests.

## Goals / Non-Goals

**Goals:**

- Deploy a RabbitMQ broker (AMQP 0-9-1) as a Kubernetes StatefulSet managed by `workshop-platform`.
- Expose the broker inside the cluster via a stable ClusterIP Service and headless Service for StatefulSet DNS.
- Define the `rabbitmq-credentials` Secret name, namespace, and required keys so application repos have a stable contract.
- Extend `scripts/validate-k8s-manifests.sh` to cover the new manifests.
- Document internal hostname, port, and Secret contract in `docs/architecture.md`.

**Non-Goals:**

- High-availability or clustered RabbitMQ (single-replica is sufficient for cost and scope).
- External (public) exposure of RabbitMQ — the broker is internal only.
- Queue/exchange topology — that belongs to application repos.
- TLS termination for AMQP (plain AMQP 5672 is sufficient for in-cluster traffic).
- Terraform-managed RabbitMQ (AmazonMQ or equivalent) — adds cost and AWS dependency.

## Decisions

### StatefulSet over Deployment

RabbitMQ requires stable network identity and persistent storage for its Mnesia database. A StatefulSet provides both. A Deployment with a PVC attachment is viable but less idiomatic for stateful workloads.

Alternatives considered: plain Deployment — rejected because restarts without persistent storage lose queue state; AmazonMQ — rejected because it adds cost and requires Terraform changes outside the approved scope.

### Shared `rabbitmq` namespace

Placing the broker in a dedicated `rabbitmq` namespace rather than `stag` or `prod` makes it a true shared resource and avoids coupling the broker lifecycle to environment-specific namespace teardown.

Application workloads in `stag` or `prod` reach the broker at `rabbitmq.rabbitmq.svc.cluster.local:5672`. This is an explicit decision: the broker is environment-agnostic for the cost profile of a single shared cluster.

Alternatives considered: one broker per namespace — rejected because it doubles resource use on a `t3.small` node and is unnecessary for Phase 4 scope.

### Secret contract over ConfigMap for credentials

Credentials (username, password, connection URL) are stored in a Kubernetes Secret. The Secret is pre-created in the `rabbitmq` namespace and referenced by application workloads via `secretKeyRef`. This keeps credentials out of manifests and avoids hard-coded values in application repos.

The Secret name is `rabbitmq-credentials` and lives in the `rabbitmq` namespace. Application workloads that need cross-namespace Secret access should use a namespace-local copy (managed by each application repo) or rely on a future secret synchronization mechanism if added to the platform.

### RabbitMQ image: official Docker Hub tag

Use `rabbitmq:3.13-management` (official image, `management` plugin included) pinned to a minor version tag. The management plugin enables the HTTP management API on port 15672 for operator inspection without requiring a separate plugin installation step.

## Risks / Trade-offs

- **Single-node, no HA** → Broker restart causes message loss for un-acked in-flight messages. Mitigation: publishers and consumers must implement reconnect logic (application responsibility).
- **Shared cluster namespace** → `stag` and `prod` workloads share the same broker and credential Secret. Queue naming conventions (e.g., `stag.*` vs `prod.*`) are the application's responsibility. Mitigation: document the convention in `docs/architecture.md`.
- **PersistentVolumeClaim on EBS** → If the node is replaced, the PVC must rebind. The EKS default StorageClass (gp2/gp3) handles this transparently in the same AZ, but a multi-AZ node replacement can block the pod. Mitigation: accepted trade-off for minimum-cost profile.
- **Plain AMQP (no TLS)** → In-cluster traffic is not encrypted. Mitigation: acceptable for a single-cluster, non-production-HA environment; TLS can be added in a future change.

## Migration Plan

1. Platform team merges the manifests to `stag`. The broker StatefulSet starts and the `rabbitmq-credentials` Secret is created.
2. Application repos update their Deployments to mount `rabbitmq-credentials` and set `RABBITMQ_URL`, `RABBITMQ_USER`, `RABBITMQ_PASS` env vars (cross-namespace Secret references must be copied to the target namespace by the application repo or a future platform Secret sync mechanism).
3. No rollback beyond deleting the new manifests; StatefulSet deletion removes the PVC only if `persistentVolumeReclaimPolicy` is `Delete`.

## Open Questions

- Should the platform provide a namespace-local Secret copy mechanism (e.g., using `ClusterRole`/`RoleBinding` to allow cross-namespace reads, or a sync job)? **Decision deferred** to application repos for Phase 4 scope.
- Should default vhosts or users beyond `admin` be pre-created? **Decision deferred** — a single `admin` user with full permissions is sufficient for Phase 4.
