# GitHub Module Implementation TODO

## Implemented Features ✅

- [x] GitHub provider ~> 6.0 with terraform >= 1.5
- [x] GCS backend using shared state bucket with prefix `terraform/github`
- [x] GitHub App authentication from Secret Manager (automatic, no manual token management)
- [x] Teams module with drift tolerance
- [x] Secrets module syncing from GCP Secret Manager to GitHub org secrets
- [x] Organization settings resource (continuous management with drift tolerance)

## Out of Scope (Manual Management)

**Repository Management** - Not managed by platform terraform:
- Repositories are created and managed manually via GitHub UI
- Branch protection rules configured manually per repository
- Repository-specific labels managed manually
- Repository team permissions managed manually via GitHub UI

**Rationale:** For small teams (<10 people), manual repository management via GitHub UI provides better flexibility without the overhead of maintaining terraform state for every repository. Platform focuses on organization-level governance (teams, secrets, org settings) only.

**Unused Modules:** The `modules/organization` and `modules/branch_protection` directories exist but are not wired up in `main.tf` and can be safely deleted.

## Drift Tolerance Model

**Continuous management with drift tolerance:**
- Terraform manages organization settings, teams, and secrets
- Manual changes to specific fields (team memberships, secret values) are preserved via `lifecycle { ignore_changes }`
- Terraform enforces critical settings (2FA, base permissions) on every apply
- Team structure and secrets are bootstrapped by terraform but tolerate manual changes
