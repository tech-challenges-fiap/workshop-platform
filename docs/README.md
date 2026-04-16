# workshop-platform docs

This directory explains how `workshop-platform` should evolve into the shared
infrastructure repository for the workshop platform split.

## Read This First

- Start with [../README.md](../README.md) for the repository purpose, commands, and delivery flow.
- Read [architecture.md](architecture.md) before deciding whether infrastructure work belongs here.
- Read [development.md](development.md) before changing Terraform, Kubernetes manifests, or CI behavior.
- Read [../AGENTS.md](../AGENTS.md) if you are using an AI agent in this repository.

## Document Map

- [architecture.md](architecture.md) - current boundaries, dependencies, and target platform role
- [development.md](development.md) - Terraform/Kubernetes workflow, validation commands, and doc rules
- [../AGENTS.md](../AGENTS.md) - repo instructions for AI agents
- [../.ai/project-context.md](../.ai/project-context.md) - compact AI-readable project context
- [../.ai/contributing.md](../.ai/contributing.md) - AI-assisted change checklist
- [../.ai/task-template.md](../.ai/task-template.md) - reusable task brief template

## Who Should Read What

- Engineers new to the repo: `README.md` then `development.md`
- Engineers deciding ownership boundaries: `architecture.md`
- AI-assisted contributors: `AGENTS.md` and `.ai/project-context.md`
