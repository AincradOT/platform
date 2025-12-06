# Setup

Deploying the platform from scratch.

## Prerequisites

Before starting, complete the [Requirements](../requirements.md):

- GCP organization with billing account
- Cloud Identity or Google Workspace
- Domain registered (for Cloudflare)
- `gcloud` CLI installed and authenticated

## Bootstrap the platform

Follow the [Platform README](../platform/README.md) for complete bootstrap procedure.

**Quick overview:**

1. Authenticate with `gcloud`
2. Configure and apply `0-bootstrap`
3. Apply `1-org`
4. Apply `2-environments/development` and `2-environments/production`

Time: ~30 minutes

## Terraform roots

Each terraform root has its own README with configuration details:

- [platform/](../platform/README.md) - Overview and bootstrap procedure
- [0-bootstrap/](../platform/0-bootstrap/README.md) - Bootstrap project and state bucket
- [1-org/](../platform/1-org/README.md) - Organizational folders and logging
- [2-environments/development/](../platform/2-environments/development/README.md) - Dev environment
- [2-environments/production/](../platform/2-environments/production/README.md) - Prod environment

## Operational runbooks

- [Bootstrap GitHub Foundation](bootstrap-github-foundation.md) - GitHub organization setup
- [Add Project Repository](add-new-project-repo.md) - Onboard application repos
- [Onboard Developer](onboard-developer.md) - Add team members

## After bootstrap

Application repos consume the platform - see [Golden Path](../golden-path.md) for patterns.
