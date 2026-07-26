# workshop-platform Architecture

## Role

`workshop-platform` is the shared infrastructure repository. It provisions the
AWS network and Kubernetes runtime foundation used by `workshop-app` and
published through `workshop-edge`.

## Boundaries

This repository owns:

- shared platform Terraform and naming
- VPC, subnets, route tables, EKS, managed nodes, IAM, and OIDC
- ingress-nginx installation and public load balancer exposure
- Kubernetes namespaces `stag` and `prod`
- Datadog cluster installation when enabled
- platform outputs required by app and edge deployment contracts

This repository does not own:

- application behavior, images, routes, or manifests beyond platform baseline
- edge handler implementation
- RDS, database credentials, migrations, or seed data

## Terraform Composition

The root Terraform module composes:

- `modules/network`: VPC, public/private subnets, internet gateway, route tables, and optional NAT gateway
- `modules/eks`: EKS control plane, managed node group, IAM roles, OIDC provider, core add-ons, and platform security groups
- root Kubernetes and Helm resources: namespaces, ingress-nginx, optional Datadog, and deploy access

The Terraform `environment` variable is fixed to `shared`. Runtime
environments are isolated inside the single EKS cluster through the `stag` and
`prod` namespaces.

## Cost Profile

The default configuration is optimized for minimum cost while keeping a real
EKS platform:

- `enable_nat_gateway = false`
- `node_subnet_tier = "public"`
- one managed node
- Datadog disabled

This avoids the fixed NAT Gateway cost. Use `node_subnet_tier = "private"` with
`enable_nat_gateway = true` when private node networking is required.

## Deployment Interfaces

`workshop-app` consumes:

- `cluster_name`
- `cluster_region`
- `deploy_role_arn`
- `namespace_stag`
- `namespace_prod`
- ingress hostname for the target environment

`workshop-edge` consumes:

- `ingress_hostname_stag`
- `ingress_hostname_prod`

`workshop-db` can consume:

- `vpc_id`
- `private_subnet_ids`
- `workload_security_group_id`

The database repository remains responsible for database provisioning and
secret ownership. This platform repository only exposes network and security
group contracts needed for connectivity.

## Environment Isolation

The cluster contains separate `stag` and `prod` namespaces. The generated
`deploy_role_arn` receives namespace-scoped edit access to those namespaces
through EKS access entries and access policy associations.

## Phase 4 Service Deployment Baseline

The Kubernetes base defines independent placeholder Deployments, ConfigMaps, and
ClusterIP Services for the Phase 4 application services in the `stag` namespace:

| Service | Deployment | ConfigMap | Internal DNS | Service port |
|---|---|---|---|---|
| Order Service (OS) | `order-service` | `order-service-config` | `order-service.stag.svc.cluster.local` | `80` -> container `8080` |
| Billing Service | `billing-service` | `billing-service-config` | `billing-service.stag.svc.cluster.local` | `80` -> container `8080` |
| Execution Service | `execution-service` | `execution-service-config` | `execution-service.stag.svc.cluster.local` | `80` -> container `8080` |

Each Deployment uses a deliberately non-runnable placeholder image under
`example.invalid/workshop/<service>:replace-me`. Application delivery workflows
or service repositories must replace those images before applying the manifests
to a live cluster. The platform repository owns the Kubernetes object shape,
labels, selectors, service names, and baseline runtime wiring only.

The service ConfigMaps provide platform-level defaults such as `SERVICE_NAME`,
`APP_ENV`, `RABBITMQ_HOST`, `RABBITMQ_PORT`, and peer service URLs where a
service needs to call another internal service. Each service Deployment also
imports the shared `correlation-observability-config` ConfigMap described below.
Application-specific behavior, message handlers, database credentials,
queue/exchange declarations, and public edge routing remain outside this
repository.

Production can reuse the same object contract through a future overlay or
release-time namespace/environment patches. This change does not add a new
production overlay or claim that production images are available here.

## Shared Message Broker

A RabbitMQ broker is deployed as a single-replica StatefulSet in the `rabbitmq`
namespace and is reachable by workloads in any namespace via internal DNS.

| Property | Value |
|---|---|
| Internal hostname | `rabbitmq.rabbitmq.svc.cluster.local` |
| AMQP port | `5672` |
| Management API port | `15672` |
| Credentials Secret name | `rabbitmq-credentials` |
| Credentials Secret namespace | `rabbitmq` |

The Secret contains three keys:

- `RABBITMQ_USER` — broker admin username
- `RABBITMQ_PASS` — broker admin password
- `RABBITMQ_URL` — full AMQP connection URL (`amqp://<user>:<pass>@rabbitmq.rabbitmq.svc.cluster.local:5672/`)

Application workloads reference these via `secretKeyRef`. Because the Secret
lives in the `rabbitmq` namespace, application repos that need the values in
`stag` or `prod` must copy the Secret into their own namespace (or use an
external-secrets / sealed-secrets workflow).

**Queue naming convention:** prefix all queue names with the environment to
avoid cross-environment collisions on the shared broker — `stag.<queue>` for
staging workloads and `prod.<queue>` for production workloads.

## Observability

Datadog is installed through Helm only when `enable_datadog` is true. In that
mode, `datadog_api_key` must come from a secure variable source or the
`DATADOG_API_KEY` GitHub Actions secret.

### Phase 4 Correlation Observability Conventions

The Kubernetes base defines a platform-level ConfigMap named
`correlation-observability-config` in the `stag` namespace. OS, Billing, and
Execution Deployments import it with `envFrom.configMapRef` alongside their
service-specific ConfigMaps. The ConfigMap exposes stable names that application
runtimes should use when implementing correlation ID propagation and telemetry:

| Environment variable | Value | Intended use |
|---|---|---|
| `CORRELATION_ID_HTTP_HEADER` | `X-Correlation-Id` | HTTP request/response propagation header |
| `CORRELATION_ID_MESSAGE_HEADER` | `correlationId` | RabbitMQ message header/property key |
| `CORRELATION_ID_LOG_FIELD` | `correlationId` | Structured log field name |
| `CORRELATION_ID_METRICS_LABEL` | `correlation_id` | Metrics label name |
| `CORRELATION_ID_PROPAGATION_TARGETS` | `http,rabbitmq,logs,metrics` | Target-state signal surfaces |
| `CORRELATION_ID_GENERATION_POLICY` | `application-runtime` | Documents that services, not the platform, create or reuse IDs |
| `OBSERVABILITY_STACK_STATUS` | `convention-only` | Indicates that this manifest is a convention, not a live collector/dashboard |

The three Phase 4 Deployments and Pod templates carry
`observability.workshop.io/correlation-id: enabled` plus annotations naming the
expected HTTP header, message header, log field, and metrics label. These labels
and annotations are discovery metadata for future log, metric, or trace tooling.
They do not emit telemetry by themselves.

Application repositories remain responsible for creating a correlation ID when
an inbound request/message lacks one, propagating it on downstream HTTP calls and
RabbitMQ messages, writing it to structured logs as `correlationId`, and adding
it to metrics only where cardinality and privacy controls permit. This platform
change does not add application middleware, RabbitMQ handlers, log formatters,
metrics emitters, dashboards, alert rules, OpenTelemetry Collector resources, or
Datadog runtime configuration. Centralized correlation views exist only if an
observability stack is enabled and configured separately.
