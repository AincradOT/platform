# 3-github

GitHub organization infrastructure managed as code.

## What this creates

- Organization-level secrets (GitHub App credentials synced from Secret Manager to GitHub)
- Teams and team memberships
- Organization settings and policies (excluding billing, which remains manual)

**Note:** This module automatically reads GitHub App credentials from GCP Secret Manager (stored by 1-org) for authentication. No manual credential configuration required.

## Prerequisites

1. Complete [Manual Setup](../../docs/requirements.md) including GitHub App creation
2. GitHub App credentials stored in Secret Manager via `1-org` (step 9 in platform/README.md)
3. GitHub App must be installed to your organization
4. Complete `1-org` terraform apply to ensure secrets exist in Secret Manager

## Additional Resources

- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs) - Provider documentation
- [GitHub Apps Authentication](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app) - App authentication guide
- [GitHub Organization Settings](https://docs.github.com/en/organizations/managing-organization-settings) - Organization management

!!! note
    For step-by-step bootstrap instructions, see the [Platform README](../README.md).
    This document provides reference information for the 3-github terraform root.

## Configuration

Create `terraform.tfvars`:

```hcl
# Shared services project ID (from 1-org output)
shared_project_id = "aincrad-shared"

# GitHub organization name
github_organization = "aincradot"

# Team configuration
teams = {
  developers = {
    description = "Core developers"
    members     = ["your-github-username"]
  }
  admins = {
    description = "Organization administrators"
    members     = ["your-github-username"]
  }
}

# Organization settings (optional)
# Note: billing_email is intentionally excluded - manage billing manually via GitHub UI
org_settings = {
  company     = "Your Company"
  description = "Open Tibia game server infrastructure"
}
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `shared_project_id` | Shared services project ID where Secret Manager secrets are stored | Yes |
| `github_organization` | GitHub organization name | Yes |
| `teams` | Map of teams with members and descriptions | No (no default - must be provided) |
| `org_settings` | Organization-wide settings (billing excluded) | No (default: empty) |
| `default_branch` | Default branch name for repositories | No (default: "master") |
| `enable_advanced_security` | Enable GitHub Advanced Security features | No (default: false) |

## Outputs

- None currently exported

## Notes

- **Automatic authentication**: GitHub App credentials are read from Secret Manager automatically - no manual PEM file handling required
- **Secrets module**: Syncs GitHub App credentials from GCP Secret Manager to GitHub organization secrets for CI/CD
- **Teams module**: Creates teams with members and permissions
- **Billing exclusion**: `billing_email` in org_settings is intentionally optional and should be managed manually via GitHub UI
- **Secret Manager dependency**: Requires Secret Manager secrets created by `1-org` terraform root
