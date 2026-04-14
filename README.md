# workshop-platform

Infraestrutura base de plataforma do projeto `workshop`.

## Proposito

Este repositorio concentra VPC, EKS, IAM/OIDC, ingress, observabilidade base e
capacidades compartilhadas da plataforma. Ele nao contem regra de negocio nem
Lambdas de edge.

## Stack principal

- Terraform
- Kubernetes
- AWS

## Estrategia de deploy

- `feature/* -> stag`: Pull Request com validacao Terraform e manifestos
- `stag -> prod`: Pull Request de promocao para `production`
- autenticacao AWS via OIDC para pipelines

## Documentacao local

- [docs/README.md](docs/README.md)

