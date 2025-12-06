# Architecture

Platform architecture for Open Tibia services using GCP, GitHub, and Cloudflare.

## Design goals

- Separation of platform and application concerns
- Reproducible bootstrap with minimal manual steps
- Cheap to operate (cents per month for platform)
- Maintainable by a single dev with novice-intermediate terraform/cloud knowledge
- Explicit security boundaries

!!! note
    Read the [Golden path](../golden-path.md) first for rationale and context.

## Platform components

The platform is organized into [Terraform](https://www.terraform.io/docs) roots in a single `platform` repository:

- `0-bootstrap` creates bootstrap project and [GCS state bucket](state-management.md)
- `1-org` creates organizational folders (shared, dev, prod) and shared services project
- `2-environments` creates dev and prod environment projects

All roots use shared [GCS backend](https://www.terraform.io/docs/language/settings/backends/gcs.html) with separate state prefixes.

Application repositories use the same backend and target environment projects created by platform. They never modify organisation level resources.

## Bootstrap lifecycle

### 1. Manual setup

- Create GitHub organisation
- Create GCP organisation and billing account
- Create domain in Cloudflare
- Install and configure gcloud SDK

### 2. Platform provisioning

- Clone `platform` repository
- Run `0-bootstrap` terraform
- Migrate bootstrap state to GCS
- Run `1-org` terraform
- Run `2-environments` terraform
- Configure CI service accounts (Phase 2)

### 3. Application consumption

- Create application repositories
- Point terraform backends at shared GCS bucket
- Use org-level GitHub secrets for CI
- Use [Secret Manager](state-management.md) for application secrets
- Manage DNS via Cloudflare provider in application terraform

## Architecture pages

- [Cloudflare](cloudflare.md) - DNS self-service, TLS certs, game server TCP exposure decision
- [Google Cloud](gcp.md) - Bootstrap structure, state bucket, projects, service accounts
- [GitHub Organisation](github.md) - Terraform-managed org settings, teams, branch protections
- [Continuous Integration](ci.md) - Service account auth, GitHub Apps, workflow patterns
- [State Management](state-management.md) - GCS backend, versioning, recovery, security
- [Disaster Recovery](disaster-recovery.md) - Platform rebuild procedures, backup strategies
- [Cost Model](cost-model.md) - Platform costs ($15-18/month), optimization strategies
