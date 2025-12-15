# Platform Bootstrap

Complete step-by-step procedures for deploying the platform from scratch.

## Bootstrap Procedure

The complete bootstrap procedure is documented in the Platform README, which includes:

- Prerequisites verification
- Authentication setup
- Terraform configuration and apply sequence for all roots (0-bootstrap, 1-org, 2-environments, 3-github)
- Verification steps after each stage
- CI service account key generation and GitHub secrets configuration
- Troubleshooting common issues

**Before starting**: Complete the [Requirements](../requirements.md) to set up GCP organization, GitHub organization, and Cloudflare domain.

**After bootstrap**: Application repositories consume the platform boundaries - see the [Golden Path](../golden-path.md) for application patterns and responsibilities.

## Grant CI bucket permissions

If an application Terraform needs to create a backup bucket and fails with `storage.buckets.create`, follow [Grant CI access to manage backup buckets](ci-storage-permissions.md) to give the environment CI service account project-scoped `roles/storage.admin`.

## Teardown

To decommission the platform and stop all billing, see [Teardown](teardown.md).
