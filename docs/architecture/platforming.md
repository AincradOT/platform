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

The platform is made of two Terraform roots inside a single `foundation` repository.

- `cloud/` manages GCP organisation, environment projects, state bucket, keys and CI service accounts.
- `github/` manages GitHub organisation settings, teams, core repositories and branch protections.

Both roots use a shared Terraform backend stored in GCS, but with separate state keys.

Application repositories (for example `game-infra`, `game-server`, `web-ui`) use Terraform with the same GCS backend and environment projects that are created by the `cloud/` root. They never modify organisation level resources.

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

- Clone `foundation`.
- Run the `cloud/` Terraform roots in order.
- Run the `github/` Terraform root.
- Configure GitHub Actions for the platform repository so it can manage itself.

At the end of this phase the organisation and platform are in a known, reproducible state.

### 3. Project consumption

- Create new application or service repositories under the GitHub organisation.
- Point their Terraform backends at the shared GCS bucket.
- Use Workload Identity Federation to grant CI jobs access to GCP projects.
- Use GCP Secret Manager as the canonical store for shared secrets and Ansible lookups.

Projects can be added and removed without changing the platform foundations.
