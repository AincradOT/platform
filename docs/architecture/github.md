# GitHub platform

This section describes how we manage the GitHub organisation as part of the platform.

The GitHub organization uses **terraform for organization-level governance** with continuous management and selective drift tolerance. Terraform enforces critical policies (2FA, base permissions) while allowing operational flexibility for team memberships and repository management.

## Scope

The GitHub platform [Terraform](https://www.terraform.io/docs) root lives under `3-github/` in the `platform` repository. It manages:

- Organization-level settings (2FA requirements, base permissions, repository creation policies)
- Core [teams](https://docs.github.com/en/organizations/organizing-members-into-teams) with descriptions and privacy settings
- Organization-level encrypted secrets for CI/CD workflows

It does **not** manage:

- Individual repositories (created and managed manually via GitHub UI)
- [Branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches) (configured per-repository via GitHub UI)
- Repository-specific settings, webhooks, labels, or milestones
- Team repository permissions (assigned manually via GitHub UI)

The goal is organization-level governance via terraform, while development teams manage repositories and branch protection via GitHub UI.

## Provider and backend

[Terraform](https://www.terraform.io/docs) uses the [GitHub provider](https://registry.terraform.io/providers/integrations/github/latest/docs) with the organisation as the owner.

Example provider:

```hcl
terraform {
  backend "gcs" {
    bucket = "tf-state-platform-001"
    prefix = "github-org"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "your-org-name"
  token = var.github_token
}
```

The `github_token` is supplied via environment variable and is never committed.

## Organisation settings

We treat the following as non negotiable defaults:

- [two factor authentication](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa) required for all members
- base permission for organisation members is read, not write or admin
- repository creation is restricted to admins and specific teams if needed

Terraform manages these through `github_organization_settings`.

## Teams

Teams organize access and responsibilities. Teams are defined in terraform with drift tolerance for memberships:

- `developers` for core development team members
- `admins` for organization administrators
- Additional teams as needed for your organization

Terraform creates team structure and initial memberships. Team membership changes made via GitHub UI are preserved (drift-tolerant).

**Team repository permissions** are assigned manually via GitHub UI, not managed by terraform. This provides flexibility for development teams to manage repository access as needed.

## Organization secrets

Terraform syncs GitHub App credentials from GCP Secret Manager to GitHub organization-level encrypted secrets. These secrets are available to all repositories for CI/CD workflows.

Secret values are managed via Secret Manager and automatically synced to GitHub. Changes to secret values in Secret Manager are preserved (drift-tolerant).
