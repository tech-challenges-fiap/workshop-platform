# workshop-platform project context

## Purpose

`workshop-platform` is the shared infrastructure repository. It owns common
platform capabilities rather than application or database-specific behavior.

## Current State

- Terraform naming baseline
- minimal Kubernetes namespace package
- manifest validation script
- CI validation for Terraform and manifest structure

## Operating Constraint

- keep the repository focused on shared infrastructure
- treat application behavior, handler implementation, and database provisioning as out of scope
- document only resources and interfaces defined here

## Important Workflow

- develop on `feature/*`
- merge into `stag`
- promote from `stag` to `prod`
- validate both Terraform and Kubernetes changes before proposing them
