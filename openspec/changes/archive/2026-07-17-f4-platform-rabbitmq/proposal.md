## Why

Phase 4 of the FIAP Tech Challenge introduces asynchronous messaging between the Order, Billing, and Execution microservices. The platform must expose a shared RabbitMQ broker — deployed inside the EKS cluster — so application repos can publish and consume events without owning the broker lifecycle.

## What Changes

- Add `kubernetes/base/rabbitmq/` with a StatefulSet, headless Service, ClusterIP Service, ConfigMap, and Secret template for the RabbitMQ broker.
- Add the RabbitMQ resources to the Kustomize base (`kubernetes/base/kustomization.yaml`).
- Add a Kubernetes Secret template (name convention and expected keys) so application repos know how to reference broker credentials.
- Extend `scripts/validate-k8s-manifests.sh` to cover the new manifests.
- Document service discovery hostname, port contract, and credential Secret structure in `docs/architecture.md`.

## Capabilities

### New Capabilities

- `platform-rabbitmq`: Shared RabbitMQ broker running as a Kubernetes StatefulSet inside the cluster, reachable by application workloads in `stag` and `prod` namespaces via internal DNS.

### Modified Capabilities

- None.

## Impact

- `workshop-app` (and any Phase 4 microservice repo) will mount the `rabbitmq-credentials` Secret to obtain `RABBITMQ_URL`, `RABBITMQ_USER`, and `RABBITMQ_PASS`.
- No Terraform changes are required; the broker runs inside the existing EKS cluster using current namespace resources.
- `scripts/validate-k8s-manifests.sh` gains coverage of the new manifests.
- `docs/architecture.md` gains the internal broker hostname and port contract.
