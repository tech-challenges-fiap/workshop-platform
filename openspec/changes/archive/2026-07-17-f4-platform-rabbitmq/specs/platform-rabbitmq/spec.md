## ADDED Requirements

### Requirement: RabbitMQ StatefulSet deployed in cluster

The platform SHALL deploy a single-replica RabbitMQ StatefulSet named `rabbitmq` in the `rabbitmq` Kubernetes namespace using the official `rabbitmq:3.13-management` image.

#### Scenario: StatefulSet is created and reaches Ready state

- **WHEN** the Kustomize base manifests are applied to the cluster
- **THEN** a StatefulSet named `rabbitmq` in namespace `rabbitmq` SHALL exist with `readyReplicas == 1`

#### Scenario: Broker persists queue state across pod restarts

- **WHEN** the RabbitMQ pod is deleted and rescheduled
- **THEN** the StatefulSet SHALL reattach the same PersistentVolumeClaim and queue state SHALL be preserved

### Requirement: Internal service discovery via ClusterIP Service

The platform SHALL expose a ClusterIP Service named `rabbitmq` in the `rabbitmq` namespace on port 5672 (AMQP) and port 15672 (management HTTP API). Application workloads in any namespace SHALL reach the broker at `rabbitmq.rabbitmq.svc.cluster.local:5672`.

#### Scenario: AMQP connection from application namespace

- **WHEN** a workload in the `stag` or `prod` namespace opens a TCP connection to `rabbitmq.rabbitmq.svc.cluster.local:5672`
- **THEN** the connection SHALL be accepted by the RabbitMQ broker

#### Scenario: Management API reachable inside the cluster

- **WHEN** a workload sends an HTTP GET to `http://rabbitmq.rabbitmq.svc.cluster.local:15672/api/overview`
- **THEN** the RabbitMQ management API SHALL return HTTP 200

### Requirement: Headless Service for StatefulSet DNS

The platform SHALL expose a headless Service named `rabbitmq-headless` in the `rabbitmq` namespace so the StatefulSet pod receives a stable DNS entry at `rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local`.

#### Scenario: Pod-stable hostname resolves

- **WHEN** a DNS lookup is performed for `rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local`
- **THEN** the lookup SHALL return the IP address of the `rabbitmq-0` pod

### Requirement: Credentials Secret with stable key contract

The platform SHALL create a Kubernetes Secret named `rabbitmq-credentials` in the `rabbitmq` namespace containing at minimum the following keys:

- `RABBITMQ_USER` — broker admin username
- `RABBITMQ_PASS` — broker admin password
- `RABBITMQ_URL` — full AMQP connection URL in the form `amqp://<user>:<pass>@rabbitmq.rabbitmq.svc.cluster.local:5672/`

Application repos SHALL reference these keys via `secretKeyRef` when configuring their workloads.

#### Scenario: Secret exists after manifest apply

- **WHEN** the Kustomize base manifests are applied
- **THEN** a Secret named `rabbitmq-credentials` in namespace `rabbitmq` SHALL exist with keys `RABBITMQ_USER`, `RABBITMQ_PASS`, and `RABBITMQ_URL`

#### Scenario: Application workload mounts credentials

- **WHEN** a Deployment in the `stag` or `prod` namespace references `rabbitmq-credentials` from the `rabbitmq` namespace via `secretKeyRef`
- **THEN** the pod SHALL receive the correct credential values as environment variables

### Requirement: Dedicated rabbitmq namespace

The platform SHALL create and manage a Kubernetes namespace named `rabbitmq` with the label `app.kubernetes.io/managed-by: workshop-platform`. This namespace SHALL be included in the Kustomize base alongside `stag` and `prod`.

#### Scenario: Namespace exists after manifest apply

- **WHEN** the Kustomize base manifests are applied
- **THEN** a namespace named `rabbitmq` SHALL exist with label `app.kubernetes.io/managed-by: workshop-platform`

### Requirement: Manifest validation coverage

The platform's `scripts/validate-k8s-manifests.sh` SHALL validate all manifests under `kubernetes/base/rabbitmq/` in addition to existing resources.

#### Scenario: Validation script covers new manifests

- **WHEN** `./scripts/validate-k8s-manifests.sh` is run locally or in CI
- **THEN** it SHALL process and lint all YAML files under `kubernetes/base/rabbitmq/` without errors

### Requirement: Architecture documentation for internal broker

`docs/architecture.md` SHALL document the following for consumers:

- Internal hostname: `rabbitmq.rabbitmq.svc.cluster.local`
- AMQP port: `5672`
- Management API port: `15672`
- Secret name and namespace: `rabbitmq-credentials` in namespace `rabbitmq`
- Queue naming convention: prefix queues with the environment (`stag.` or `prod.`) to avoid cross-environment collisions on the shared broker

#### Scenario: Documentation is present after change implementation

- **WHEN** a developer reads `docs/architecture.md`
- **THEN** they SHALL find the broker hostname, port, Secret contract, and queue naming convention documented
