# Architecture

Platform architecture for Open Tibia services using GCP, GitHub, and Cloudflare.

!!! note
    Read the [Golden path](../golden-path.md) first for rationale, design goals, and context.

## Platform components

The platform is organized into [Terraform](https://www.terraform.io/docs) roots in a single `platform` repository:

- `0-bootstrap` creates bootstrap project and [GCS state bucket](state-management.md)
- `1-org` creates organizational folders (shared, dev, prod) and shared services project
- `2-environments` creates dev and prod environment projects
- `3-github` creates GitHub organization settings, teams, and secrets

All roots use shared [GCS backend](https://www.terraform.io/docs/language/settings/backends/gcs.html) with separate state prefixes.

Application repositories use the same backend and target environment projects created by platform. They never modify organisation level resources.

## Bootstrap and application flow

For complete bootstrap procedures, see the [Platform README](../../platform/README.md).

## State and remote backends

See [State Management](state-management.md) for complete details on:
- GCS bucket configuration and features
- State prefixes and isolation
- State locking considerations
- Bootstrap state migration process

Applications consume platform resources:

- Point terraform backends at shared GCS bucket with unique prefixes
- Use org-level GitHub secrets for CI authentication
- Read Cloudflare API tokens from Secret Manager
- Manage application-specific DNS records via Cloudflare provider

## Architecture pages

- [Cloudflare](cloudflare.md) - DNS self-service, TLS certs, game server TCP exposure decision
- [Google Cloud](gcp.md) - Bootstrap structure, state bucket, projects, service accounts
- [GitHub Organisation](github.md) - Terraform-managed org settings, teams, branch protections
- [Continuous Integration](ci.md) - Service account auth, GitHub Apps, workflow patterns
- [State Management](state-management.md) - GCS backend, versioning, recovery, security
- [Disaster Recovery](disaster-recovery.md) - Platform rebuild procedures, backup strategies
- [Cost Model](cost-model.md) - Platform costs ($15-18/month), optimization strategies

## External Resources

**Terraform:**
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) - Complete resource reference
- [Terraform Best Practices](https://www.terraform-best-practices.com/) - Community best practices guide
- [GCS Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) - State backend setup

**Google Cloud Platform:**
- [GCP IAM Documentation](https://cloud.google.com/iam/docs) - Roles, permissions, service accounts
- [GCS Documentation](https://cloud.google.com/storage/docs) - Cloud Storage features and API
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs) - Managing application secrets
- [GCP Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations) - Organization structure patterns

**GitHub:**
- [GitHub Actions Documentation](https://docs.github.com/en/actions) - Workflow automation
- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs) - Managing GitHub via Terraform
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches) - Repository protection

**Cloudflare:**
- [Cloudflare Terraform Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs) - DNS and edge configuration
- [Cloudflare API Documentation](https://developers.cloudflare.com/api/) - API reference
