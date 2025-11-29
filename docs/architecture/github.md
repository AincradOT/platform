# GitHub foundation

This section describes how we manage the GitHub organisation as part of the platform.

## Scope

The GitHub foundation Terraform root lives under `github/` in the `foundation` repository. It manages:

- organisation level settings
- core teams and their permissions
- core repositories that must always exist
- branch protection rules for main and production branches
- standard labels and other repository level defaults

It does **not** attempt to manage every user membership or every ad hoc repository. The goal is to codify the critical structure and guardrails, not micromanage everything through Terraform.

## Provider and backend

Terraform uses the GitHub provider with the organisation as the owner.

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

- two factor authentication required for all members
- base permission for organisation members is read, not write or admin
- repository creation is restricted to admins and specific teams if needed

Terraform manages these through `github_organization_settings`.

## Teams

Teams organise access and responsibilities. The initial set might look like:

- `platform` for engineers who manage GCP and GitHub foundations
- `game` for game server and game infrastructure work
- `web` for the web application and launcher
- `readers` for people who need code visibility but no write access

Terraform defines team names and slugs, and binds them to repositories with a clear permission level:

- `platform` team has maintain rights on `foundation` and read on everything else
- `game` team has write or maintain rights on `game-infra` and `game-server`
- `web` team has write or maintain rights on `web-ui`

Individual human membership in teams can be managed manually at first, or codified later if needed.

## Core repositories

We treat several repositories as part of the platform:

- `foundation`
- `game-infra`
- `game-server`
- `web-ui`
- any other truly core repos

Terraform ensures these repositories exist with the correct visibility, default branch and topics. If they are accidentally deleted or misconfigured, a Terraform apply will restore them.

Non core repositories can still be created manually when needed. If a repository becomes critical, it should be added to the Terraform configuration.

## Branch protection

Branch protection rules are essential for keeping infrastructure and core services stable.

Terraform manages branch protection for at least:

- the `main` branch in every core repository
- a `prod` or `release` branch where one exists

Typical rules:

- require pull requests for changes
- require status checks to pass before merging
- disallow force pushes
- restrict who can push directly

We should avoid overcomplicating branch rules. The goal is to prevent obvious foot guns, not block every edge case.

## Labels and templates

Standard issue labels and optionally basic issue and pull request templates help new projects look consistent.

Terraform can create a minimal label set in core repositories. It is not mandatory to manage every label as code, but the important ones should be codified so they are present everywhere:

- `infra`
- `ops`
- `bug`
- `enhancement`
- `security`
