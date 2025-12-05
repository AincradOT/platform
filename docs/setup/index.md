# Setup

Bootstrap procedures and terraform configuration for platform deployment.

## What this covers

This section walks through deploying the platform from scratch:

- Prerequisites (Cloud Identity, billing, domain)
- Bootstrap terraform roots (projects, state, folders)
- Platform terraform configuration reference

## Deploy order

1. **Manual prerequisites** - One-time setup: GCP org, billing, domain, gcloud CLI
2. **0-bootstrap** - Creates bootstrap project and GCS state bucket (local backend initially)
3. **1-org** - Creates organizational folders and shared logging project
4. **2-environments** - Creates dev and production environment projects

Total time: 2-3 hours for experienced engineers.

!!! note
    Prerequisites are documented in [Requirements](../requirements.md). Start there if this is your first deployment.

## Runbooks

Step-by-step procedures:

- [Bootstrap GCP Foundation](bootstrap-gcp-foundation.md) - Deploy platform terraform roots
- [Bootstrap GitHub Foundation](bootstrap-github-foundation.md) - GitHub organization setup
- [Add Project Repository](add-new-project-repo.md) - Onboard application repositories
- [Onboard Developer](onboard-developer.md) - Add team members

## Terraform configuration

Detailed reference for each terraform root:

- [Overview](../platform/README.md) - Platform design and prerequisites
- [0-bootstrap](../platform/0-bootstrap/README.md) - Bootstrap project and state bucket
- [1-org](../platform/1-org/README.md) - Organizational structure
- [2-environments/dev](../platform/2-environments/development/README.md) - Development environment
- [2-environments/prod](../platform/2-environments/production/README.md) - Production environment

## After bootstrap

Once platform is deployed:

- Application repos consume the platform (they don't modify it)
- Use shared GCS state bucket with unique prefixes
- Target environment projects created by platform
- Read secrets from Secret Manager (when implemented)

See [Golden Path](../golden-path.md) for application repository patterns.
