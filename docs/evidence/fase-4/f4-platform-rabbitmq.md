# Evidence — f4-platform-rabbitmq

**Change ID:** f4-platform-rabbitmq  
**Repository:** workshop-platform  
**Date:** 2026-07-17  
**Checklist columns supported:** Foundation / Infrastructure / Messaging

---

## Change Summary

Adds RabbitMQ to the Kubernetes platform for Phase 4 inter-service messaging. Creates the `rabbitmq` namespace, ConfigMap, Secret template, StatefulSet (single replica, rabbitmq:3.13-management), ClusterIP Service (AMQP 5672 / management 15672), and headless Service for StatefulSet DNS. Wires all manifests into the Kustomize base. Updates the validation script and architecture documentation.

**Artifacts created/modified:**
- `kubernetes/base/namespaces.yaml` — `rabbitmq` namespace
- `kubernetes/base/rabbitmq/configmap.yaml`
- `kubernetes/base/rabbitmq/secret.yaml`
- `kubernetes/base/rabbitmq/statefulset.yaml`
- `kubernetes/base/rabbitmq/service.yaml`
- `kubernetes/base/rabbitmq/service-headless.yaml`
- `kubernetes/base/kustomization.yaml` — rabbitmq resources added
- `scripts/validate-k8s-manifests.sh` — rabbitmq/ path added
- `docs/architecture.md` — broker hostname, ports, Secret name, queue naming convention
- `openspec/changes/f4-platform-rabbitmq/` — proposal, design, spec, tasks

---

## Validation Commands and Results

### 1. Terraform Format Check

```
$ cd /root/repos/tech-challenges-fiap/workshop-platform
$ terraform -chdir=terraform fmt -check -recursive
(exit 0 — no formatting issues)
```

**Result: PASSED**

### 2. Terraform Init

```
$ terraform -chdir=terraform init -backend=false
...initialized.
```

**Result: PASSED**

### 3. Terraform Validate

```
$ terraform -chdir=terraform validate
Success! The configuration is valid.
```

**Result: PASSED**

### 4. Kubernetes Manifests Validation

```
$ bash ./scripts/validate-k8s-manifests.sh
Validated Kubernetes manifests: 7
```

**Result: PASSED — 7 manifests validated**

### 5. OpenSpec Validation

```
$ npx --yes @fission-ai/openspec validate f4-platform-rabbitmq --strict
Change 'f4-platform-rabbitmq' is valid
```

**Result: PASSED**

---

## Archive Status

All validations passed. Change archived via:
```
npx --yes @fission-ai/openspec archive f4-platform-rabbitmq --yes
```
Archive record: `openspec/changes/archive/2026-07-17-f4-platform-rabbitmq/`  
Archive command output: `Change 'f4-platform-rabbitmq' archived as '2026-07-17-f4-platform-rabbitmq'.` (Task status: Complete)
