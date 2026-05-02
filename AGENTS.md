# AGENTS.md

## Mission

Work in `workshop-platform` as a shared infrastructure repository. Keep this
repo focused on platform-level Terraform, Kubernetes baseline manifests, and
shared delivery conventions.

## Scope Boundaries

In scope:

- Terraform in `terraform/`
- Kubernetes manifests in `kubernetes/`
- platform validation scripts in `scripts/`
- platform-focused documentation

Out of scope:

- application runtime behavior
- handler implementation and edge-specific integrations
- database provisioning

## Read First

- `README.md`
- `docs/architecture.md`
- `docs/development.md`
- `terraform/main.tf`
- `terraform/variables.tf`
- `kubernetes/base/kustomization.yaml`
- `scripts/validate-k8s-manifests.sh`

## Validation Commands

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -var="environment=stag" -var="repo=platform"
cd ..
./scripts/validate-k8s-manifests.sh
```

Run all relevant validation for any Terraform or Kubernetes change. For
documentation-only changes, still verify that documented commands and paths are
correct.

## Workflow Rules

- Always run `git fetch origin --prune` before starting work.
- Always create a new branch from the updated `origin/stag`.
- Always open feature, fix, docs, and maintenance PRs into `stag`.
- Never open a direct PR to `prod`.
- Treat `prod` as promotion-only and update it only through the `stag -> prod` promotion PR.
- Before opening or updating a PR, verify that your branch is still based on current `origin/stag`.
- Stage files explicitly when the worktree contains unrelated changes.
- Never push directly to `stag` or `prod`.

## CI And Completion Rules

- Before saying the task is done, check the PR's required CI statuses.
- If CI fails, try to fix it once.
- If CI still fails after one reasonable fix attempt, stop and ask for help with the failure details.
- When reporting completion, include the branch name, PR URL, CI status, and any remaining blocker or risk.

## Promotion Rules

- Promotion PRs must always be `stag -> prod`.
- Promotion PRs must be merged with a merge commit.
- Do not use squash or rebase merges for promotions.

## Conflict Handling

- If a `stag -> prod` PR conflicts, do not create a direct branch or PR into `prod`.
- First inspect whether the conflict comes from broken promotion ancestry or from real content divergence.
- If branch protection or repository policy blocks the repair, stop and explain the exact maintainer action required.

## Writing Rules

- Write docs and AI guidance in English
- Do not invent platform resources that the repo does not define
- Keep platform responsibilities separate from application, delivery, and database concerns
- Treat target-state architecture as intent, not as implemented fact

## Documentation Expectations

Update `README.md`, `docs/`, and `.ai/` when you change:

- Terraform interfaces
- Kubernetes manifest layout
- validation commands
- deployment workflow behavior
- repository boundaries
