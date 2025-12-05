# Aincrad Platform

This repository defines the platform infrastructure for the SAO/Aincrad organisation, but is **designed to be lifted and shifted** for other projects.

## Purpose

This platform applies [CNCF](https://www.cncf.io/) principles using minimal-cost services from major providers ([GCP](https://cloud.google.com/), [Terraform](https://www.terraform.io/), [Cloudflare](https://www.cloudflare.com/)) to deliver:

- Professional-grade infrastructure at startup costs (~$125-145/month total)
- Industry-aligned security and operational practices with documented tradeoffs
- Reproducible environments managed as code
- Clear separation between platform and application concerns

### Pragmatic tradeoffs for cost/complexity

- No native state locking (GCS limitation, mitigated by small team sequential workflows)
- Service account keys with rotation instead of Workload Identity Federation (simpler ops)
- Game servers exposed directly to internet (cost optimization, common in gaming industry)
- Single region deployment (multi-region is enterprise-grade, not startup-grade)

### Target use case

Small-to-medium game servers (particularly [Open Tibia](https://github.com/otland/forgottenserver)), web applications, or similar stacks where at least one team member understands infrastructure and can work with [Terraform](https://www.terraform.io/docs), [GCP](https://cloud.google.com/), and CI/CD concepts.

## Why this exists

Ongoing infrastructure management shouldn't be a full-time job. This platform handles:

- [GCP](https://cloud.google.com/) organisation layout and environment [projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- Shared [Terraform state backend](architecture/state-management.md)
- [Secret Manager](https://cloud.google.com/secret-manager/docs) for application secrets
- CI [service accounts](https://cloud.google.com/iam/docs/service-accounts) for [GitHub Actions](https://docs.github.com/en/actions)
- [DNS](architecture/cloudflare.md) and TLS certificate automation

!!! note
    Application repositories consume the platform - they don't modify it. Development teams focus on building features for users, not fiddling with platform configuration.

## Portability

This platform is designed to be forked and adapted for other organizations:

- All identifiers (org IDs, project IDs, domains) are variables
- No vendor lock-in - backends and services have drop-in replacements
- Everything defined as code with clear documentation
- Suitable for other Open Tibia communities or similar small game server projects

!!! warning
    **Initial setup:** 2-3 hours for experienced engineers following the runbooks. Includes Cloud Identity, billing, domain setup, terraform bootstrapping, and CI configuration. Longer if debugging or learning.
    
    **Prerequisites:** Solid understanding of Linux, Terraform, GCP IAM, and CI/CD required. Not for infrastructure beginners.
    
    **Re-deployment:** ~1 hour for teams familiar with this pattern.

!!! note
    **Cost:** ~$15-18/month for platform (GCP, Cloudflare domain, GitHub Team), plus ~$110/month for VMs. See [Cost Model](architecture/cost-model.md) for details.

For the full rationale, see the [`Golden path`](golden-path.md) write-up.

## Scope

This documentation is about platforming only.

It discusses the management of:

- GCP organisation level resources
- Environment projects such as dev and prod
- Shared [Terraform state storage](architecture/state-management.md)
- [Secret Manager](https://cloud.google.com/secret-manager/docs) for application secrets
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

      Platform layout including GCP organisation structure, environment projects, [Terraform backends](architecture/state-management.md) and [GitHub organisation](architecture/github.md) wiring.

- [Runbooks](runbooks/index.md)

      Task oriented guides for common workflows such as bootstrapping the platform, adding a new environment or onboarding a new infra repository.

- [Contributing](contributing/index.md)

      Expectations and workflow for making changes to the platform platform, including review requirements and testing strategy.
