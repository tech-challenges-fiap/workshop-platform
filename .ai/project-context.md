# workshop-platform project context

## Purpose

`workshop-platform` is the shared infrastructure repository. It owns common
platform capabilities rather than application or database-specific behavior.

## Current State

- Terraform provisions VPC, subnets, route tables, EKS, managed nodes, IAM, and OIDC
- Terraform installs ingress-nginx, namespace isolation, and optional Datadog
- default examples use a shared low-cost profile with one public-subnet node and no NAT Gateway
- Kubernetes base manifests define the `stag` and `prod` namespace contract
- CI validates Terraform and manifests, then applies the shared Terraform stack from `stag` and `prod`

## Operating Constraint

- keep the repository focused on shared infrastructure
- treat application behavior, handler implementation, and database provisioning as out of scope
- document only resources and interfaces defined here
- expose network and security group outputs to database consumers without creating database resources here

## Important Workflow

- develop on `feature/*`
- merge into `stag`
- promote from `stag` to `prod`
- validate both Terraform and Kubernetes changes before proposing them
