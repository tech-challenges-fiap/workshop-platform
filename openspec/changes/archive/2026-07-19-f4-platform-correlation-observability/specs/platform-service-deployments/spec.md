## MODIFIED Requirements

### Requirement: Service runtime configuration placeholders

The platform SHALL define a ConfigMap for each Phase 4 service containing platform-level runtime placeholders for service role, environment, RabbitMQ host/port, and peer service URLs where applicable. Each Phase 4 service Deployment SHALL also consume the shared correlation observability ConfigMap so platform-level correlation naming conventions are available to application runtimes.

#### Scenario: ConfigMaps provide platform wiring defaults

- **WHEN** the Kustomize base is rendered
- **THEN** it SHALL include ConfigMaps named `order-service-config`, `billing-service-config`, and `execution-service-config`
- **AND** each ConfigMap SHALL include `SERVICE_NAME`, `APP_ENV`, `RABBITMQ_HOST`, and `RABBITMQ_PORT`

#### Scenario: Deployments consume their ConfigMap

- **WHEN** a service Deployment pod template is inspected
- **THEN** the application container SHALL import environment variables from that service's ConfigMap using `envFrom.configMapRef`
- **AND** the application container SHALL import environment variables from `correlation-observability-config` using `envFrom.configMapRef`
