# Setup

Deploying the platform from scratch.

## Prerequisites

Before starting, complete the [Requirements](../requirements.md):

- GCP organization with billing account
- Cloud Identity or Google Workspace
- Domain registered (for Cloudflare)
- `gcloud` CLI installed and authenticated

## Bootstrap the platform

Follow the [Platform README](../platform/README.md) for the complete step-by-step bootstrap procedure including:

- Authentication setup
- Terraform configuration and apply sequence
- Verification steps
- CI service account key generation

## After bootstrap

Application repos consume the platform - see [Golden Path](../golden-path.md) for patterns.

## Teardown

To decommission the platform and stop all billing, see [Teardown](teardown.md).
