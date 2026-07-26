## 1. Namespace

- [x] 1.1 Add `rabbitmq` namespace manifest to `kubernetes/base/namespaces.yaml` with label `app.kubernetes.io/managed-by: workshop-platform`.

## 2. RabbitMQ Kubernetes Manifests

- [x] 2.1 Create `kubernetes/base/rabbitmq/configmap.yaml` with RabbitMQ base configuration (default vhost `/`, loopback_users none).
- [x] 2.2 Create `kubernetes/base/rabbitmq/secret.yaml` as a Secret template for `rabbitmq-credentials` in the `rabbitmq` namespace with keys `RABBITMQ_USER`, `RABBITMQ_PASS`, and `RABBITMQ_URL`. Values are placeholders — operators replace them before apply or use a sealed-secret/external-secrets workflow.
- [x] 2.3 Create `kubernetes/base/rabbitmq/statefulset.yaml` with a single-replica StatefulSet named `rabbitmq` in namespace `rabbitmq`, using image `rabbitmq:3.13-management`, mounting the ConfigMap, referencing the Secret for credentials, and requesting a PersistentVolumeClaim for `/var/lib/rabbitmq`.
- [x] 2.4 Create `kubernetes/base/rabbitmq/service.yaml` with a ClusterIP Service named `rabbitmq` in namespace `rabbitmq` exposing port 5672 (AMQP) and 15672 (management).
- [x] 2.5 Create `kubernetes/base/rabbitmq/service-headless.yaml` with a headless Service named `rabbitmq-headless` in namespace `rabbitmq` for StatefulSet pod DNS.

## 3. Kustomize Wiring

- [x] 3.1 Add `rabbitmq/configmap.yaml`, `rabbitmq/secret.yaml`, `rabbitmq/statefulset.yaml`, `rabbitmq/service.yaml`, and `rabbitmq/service-headless.yaml` to the `resources` list in `kubernetes/base/kustomization.yaml`.

## 4. Validation Script

- [x] 4.1 Update `scripts/validate-k8s-manifests.sh` to include `kubernetes/base/rabbitmq/` in the set of paths validated (lint all YAML files in that directory).

## 5. Documentation

- [x] 5.1 Update `docs/architecture.md` to document: internal broker hostname (`rabbitmq.rabbitmq.svc.cluster.local`), AMQP port (5672), management API port (15672), Secret name and namespace (`rabbitmq-credentials` in `rabbitmq`), and queue naming convention (`stag.*` / `prod.*` prefix).

## 6. Validation

- [x] 6.1 Run `terraform fmt -check -recursive && terraform init -backend=false && terraform validate` to confirm no Terraform regressions. PASSED with Terraform v1.15.8.
- [x] 6.2 Run `./scripts/validate-k8s-manifests.sh` and confirm all manifests including the new `rabbitmq/` resources pass.
- [x] 6.3 Run `npx --yes @fission-ai/openspec validate f4-platform-rabbitmq --strict` and confirm clean.
