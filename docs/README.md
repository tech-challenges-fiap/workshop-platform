# workshop-platform docs

## Ownership

- scope: networking, EKS, IAM/OIDC, ingress, and baseline observability
- out of scope: application domain logic, migrations, and edge Lambdas

## Initial structure

- `terraform/`: platform infrastructure baseline
- `kubernetes/`: baseline manifests versioned in the repository
- `scripts/`: local and CI validations

## Environments

- branch `stag` maps to GitHub environment `staging`
- branch `prod` maps to GitHub environment `production`
- AWS naming uses `stag` and `prod` suffixes

## Expected environment variables and secrets

- `AWS_REGION`
- `AWS_ROLE_ARN`
- `EKS_CLUSTER_NAME`
- `INGRESS_DOMAIN`
- `DATADOG_API_KEY`
- `DATADOG_APP_KEY`
