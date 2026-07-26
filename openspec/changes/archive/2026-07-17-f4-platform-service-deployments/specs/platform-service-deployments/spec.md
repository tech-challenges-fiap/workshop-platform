## ADDED Requirements

### Requirement: Independent service Deployments

The platform SHALL define independent Kubernetes Deployment manifests for `order-service`, `billing-service`, and `execution-service` so each Phase 4 service can be deployed, rolled out, and scaled independently.

#### Scenario: Each service has a Deployment

- **WHEN** the Kustomize base is rendered
- **THEN** it SHALL include one Deployment named `order-service`
- **AND** one Deployment named `billing-service`
- **AND** one Deployment named `execution-service`

#### Scenario: Deployments are independently selectable

- **WHEN** an operator selects workloads by `app.kubernetes.io/name`
- **THEN** `order-service`, `billing-service`, and `execution-service` SHALL match separate label values

### Requirement: Placeholder image contract

The platform SHALL use explicit placeholder image references for OS, Billing, and Execution Deployments and SHALL document that application delivery workflows must replace those images before applying to a live cluster.

#### Scenario: Placeholder image is visible in rendered manifests

- **WHEN** the Kustomize base is rendered before release-time image patching
- **THEN** each service Deployment SHALL contain an image under `example.invalid/workshop/` with tag `replace-me`

#### Scenario: Runtime image ownership remains outside platform

- **WHEN** an application repository builds a service image
- **THEN** that repository or its delivery workflow SHALL patch the corresponding Deployment image without requiring platform repository application code changes

### Requirement: Internal ClusterIP service discovery

The platform SHALL expose each Phase 4 service through a Kubernetes ClusterIP Service on port 80 targeting container port 8080.

#### Scenario: Service resources render

- **WHEN** the Kustomize base is rendered
- **THEN** it SHALL include ClusterIP Services named `order-service`, `billing-service`, and `execution-service`

#### Scenario: Stable internal DNS names are available

- **WHEN** the manifests are applied to the `stag` namespace
- **THEN** workloads in the cluster SHALL be able to address `order-service.stag.svc.cluster.local`, `billing-service.stag.svc.cluster.local`, and `execution-service.stag.svc.cluster.local`

### Requirement: Service runtime configuration placeholders

The platform SHALL define a ConfigMap for each Phase 4 service containing platform-level runtime placeholders for service role, environment, RabbitMQ host/port, and peer service URLs where applicable.

#### Scenario: ConfigMaps provide platform wiring defaults

- **WHEN** the Kustomize base is rendered
- **THEN** it SHALL include ConfigMaps named `order-service-config`, `billing-service-config`, and `execution-service-config`
- **AND** each ConfigMap SHALL include `SERVICE_NAME`, `APP_ENV`, `RABBITMQ_HOST`, and `RABBITMQ_PORT`

#### Scenario: Deployments consume their ConfigMap

- **WHEN** a service Deployment pod template is inspected
- **THEN** the application container SHALL import environment variables from that service's ConfigMap using `envFrom.configMapRef`

### Requirement: Kustomize and validation coverage

The platform SHALL wire the OS, Billing, and Execution service manifests into `kubernetes/base/kustomization.yaml` and SHALL include their directories in Kubernetes manifest validation.

#### Scenario: Base render includes service manifests

- **WHEN** `kustomize build kubernetes/base` or `kubectl kustomize kubernetes/base` is run
- **THEN** the rendered output SHALL include the service ConfigMaps, Services, and Deployments

#### Scenario: Validation script covers service directories

- **WHEN** `./scripts/validate-k8s-manifests.sh` is run
- **THEN** it SHALL require and validate `kubernetes/base/services/order-service`, `kubernetes/base/services/billing-service`, and `kubernetes/base/services/execution-service`

### Requirement: Service deployment topology documentation

`docs/architecture.md` SHALL document the Phase 4 OS, Billing, and Execution deployment topology, including internal service names, namespace target, placeholder image ownership, and non-goals.

#### Scenario: Developer finds service deployment contract

- **WHEN** a developer reads `docs/architecture.md`
- **THEN** they SHALL find the internal DNS names, service ports, placeholder image replacement requirement, and the boundary that this repository does not implement application code or correlation observability
