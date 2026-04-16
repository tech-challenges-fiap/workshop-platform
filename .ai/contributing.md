# AI Contributing Guide

## Checklist

- confirm the requested change belongs in `workshop-platform`
- inspect `terraform/`, `kubernetes/`, `scripts/`, and current docs before editing
- keep docs in English
- do not claim shared infrastructure exists unless code or manifests define it
- run the relevant validation commands for the touched area
- update `README.md` or `docs/` if Terraform, manifests, commands, or workflows changed

## Review Focus

- repository boundary correctness
- Terraform contract accuracy
- Kubernetes manifest accuracy
- no accidental scope creep into application, delivery, or database concerns
