# Platform overview

## Design goals

- Separation of concerns between platform and project.
- Reproducible bootstrap with minimal manual steps.
- Cheap to operate. Platform overhead should be measured in cents per month.
- Simple enough that another senior engineer can own it without reverse engineering.
- Explicit security boundaries around state, secrets and CI identities.

Platform in this context means everything that exists before any application or service repository:

- cloud organisation and environment projects
- shared state and secrets stores
- identity and access for CI and humans
- source control organisation and base repository layout

## High level architecture

The platform is organized into terraform roots inside a single `platform` repository:

- `0-bootstrap` creates the bootstrap project and GCS state bucket
- `1-org` creates organizational folders (shared, dev, prod) and shared services project
- `2-environments` creates dev and prod environment projects

All roots (after bootstrap migration) use a shared GCS backend with separate state prefixes.

Application repositories use Terraform with the same GCS backend and target the environment projects created by the platform. They never modify organisation level resources.

## Lifecycle

There are three distinct phases.

### 1. One time manual bootstrap

- Create the GitHub organisation.
- Create the GCP organisation and billing account.
- Create initial owner identities on both platforms.
- Create a personal bootstrap token for GitHub.
- Install and configure the Google Cloud SDK on a trusted machine.

This phase is intentionally small and documented. Everything after this should be driven by code.

### 2. Platform provisioning

- Clone `platform` repository
- Run `0-bootstrap` terraform to create state bucket
- Migrate bootstrap state to GCS
- Run `1-org` terraform to create folders and shared project
- Run `2-environments` terraform to create dev and prod projects
- Configure CI service accounts and GitHub secrets (Phase 2)

At the end of this phase the organisation and platform are in a known, reproducible state.

### 3. Project consumption

- Create new application or service repositories under the GitHub organisation
- Point their Terraform backends at the shared GCS bucket with unique prefixes
- Use org-level GitHub secrets for CI authentication to GCP
- Use GCP Secret Manager as the canonical store for application secrets

Projects can be added and removed without changing the platform.
