# workshop-platform project context

## Purpose

`workshop-platform` is the shared infrastructure repository for the workshop
split. It should own common platform capabilities rather than application,
edge, or database-specific behavior.

## Current State

- Terraform naming baseline
- minimal Kubernetes namespace package
- manifest validation script
- CI validation for Terraform and manifest structure

## Adjacent Repositories

- `workshop-app`: application logic and service runtime
- `workshop-edge`: edge adapters and external integrations
- `workshop-db`: PostgreSQL provisioning

## Important Workflow

- develop on `feature/*`
- merge into `stag`
- promote from `stag` to `prod`
- validate both Terraform and Kubernetes changes before proposing them
