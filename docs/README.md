# workshop-platform docs

## Ownership

- escopo: rede, EKS, IAM/OIDC, ingress e observabilidade base
- fora do escopo: dominio da aplicacao, migrations e Lambdas do edge

## Estrutura inicial

- `terraform/`: baseline de infraestrutura de plataforma
- `kubernetes/`: manifestos base versionados no repositorio
- `scripts/`: validacoes locais e de CI

## Ambientes

- branch `stag` mapeada para GitHub environment `staging`
- branch `prod` mapeada para GitHub environment `production`
- naming AWS com sufixos `stag` e `prod`

## Variaveis e secrets esperados por ambiente

- `AWS_REGION`
- `AWS_ROLE_ARN`
- `EKS_CLUSTER_NAME`
- `INGRESS_DOMAIN`
- `DATADOG_API_KEY`
- `DATADOG_APP_KEY`

