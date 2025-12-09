# Aincrad Platform

This repository defines the platform infrastructure for the Aincrad Open Tibia community, but is **designed to be lifted and shifted** for other projects.

## Purpose

!!! note
    Costs are ~$15-18/month for platforming (GCP, Cloudflare domain, GitHub Team), and ~$110/month for VMs for service hosting.
    See [Cost Model](architecture/cost-model.md) for details.

This platform applies [CNCF](https://www.cncf.io/) principles using minimal-cost services from major providers ([GCP](https://cloud.google.com/), [Terraform](https://www.terraform.io/), [Cloudflare](https://www.cloudflare.com/)) to deliver:

- Professional-grade infrastructure at startup costs (~$125-145/month total)
- Industry-aligned security and operational practices with documented tradeoffs
- Reproducible environments managed as code
- Clear separation between platform and application concerns

For the full rationale, see the [`Golden path`](golden-path.md) write-up.

### Pragmatic tradeoffs for cost/complexity

- No native state locking (GCS does not provide native locking - avoid concurrent applies)
- Service account keys with rotation instead of Workload Identity Federation (simpler ops)
- Game servers exposed directly to internet (cost optimization, common in gaming industry)
- Single region deployment (multi-region is enterprise-grade, not startup-grade)

### Target use case

Small-to-medium game servers (particularly [Open Tibia](https://github.com/otland/forgottenserver)), web applications, or similar stacks where at least one team member understands infrastructure and can work with [Terraform](https://www.terraform.io/docs), [GCP](https://cloud.google.com/), and CI/CD concepts.

## Why this exists

Ongoing infrastructure management shouldn't be a full-time job. This platform handles:

- [GCP](https://cloud.google.com/) organization layout and environment [projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- Shared [Terraform state backend](architecture/state-management.md)
- [Secret Manager API](https://cloud.google.com/secret-manager/docs) enabled for applications to manage their own secrets
- CI [service accounts](https://cloud.google.com/iam/docs/service-accounts) for [GitHub Actions](https://docs.github.com/en/actions)
- [DNS](architecture/cloudflare.md) and TLS certificate automation via application repos

!!! note
    Application repositories consume the platform - they don't modify it. Development teams focus on building features for users, not fiddling with platform configuration.

## Prerequisites

See the [Requirements](requirements.md) page for complete setup instructions.

## Portability

This platform is designed to be forked and adapted for other organizations:

- All identifiers (org IDs, project IDs, domains) are variables
- No vendor lock-in - backends and services have drop-in replacements
- Everything defined as code with clear documentation
- Suitable for other Open Tibia communities or similar small game server projects

!!! warning
    **See [Requirements](requirements.md) for prerequisites and initial setup instructions.**
    **Initial setup** includes Cloud Identity, billing, domain setup, terraform bootstrapping, and CI configuration.

## Scope

This documentation is about platforming only.

It discusses the management of:

- GCP organization level resources
- Environment projects such as dev and prod
- Shared [Terraform state storage](architecture/state-management.md)
- [Secret Manager API](https://cloud.google.com/secret-manager/docs) enablement (applications create their own secrets)
- [CI identities](architecture/ci.md) and their permissions

It does not manage:

- Individual game or web workloads
- Application specific infrastructure inside environment projects
- Per project CI pipelines beyond what is needed for platform itself

Those concerns live in separate application or infrastructure repositories that consume the platform defined here.

## How to use these docs

- [Golden path](golden-path.md)

      Rationale for the platform, how it differs from legacy hosting patterns, and the core principles that guide everything else.

- [Architecture](architecture/index.md)

      Platform layout including GCP organization structure, environment projects, [Terraform backends](architecture/state-management.md) and [GitHub organization](architecture/github.md) wiring.

- [Runbooks](runbooks/index.md)

      Bootstrap procedures and terraform configuration reference for deploying the platform from scratch.

- [Contributing](contributing/index.md)

      Expectations and workflow for making changes to the platform infrastructure, including review requirements and testing strategy.

## Learning Resources

New to infrastructure as code or Google Cloud Platform?

- [Terraform Introduction](https://www.terraform.io/intro) - Core concepts and getting started guide
- [Google Cloud IAM Overview](https://cloud.google.com/iam/docs/overview) - Understanding roles, permissions, and service accounts
- [GCP Organization Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations) - Enterprise organization structure patterns
- [Infrastructure as Code Principles](https://www.hashicorp.com/resources/what-is-infrastructure-as-code) - Why IaC matters for reliability and repeatability
