# Aincrad Platform

This is the official documentation for Aincrad’s organisation platforming.

It defines:

- GCP organisation level layout and environment projects
- shared Terraform state backend and encryption
- CI service accounts and Workload Identity Federation for GitHub Actions
- GitHub organisation settings, core repositories, teams and branch protections

Application and service repositories consume these platform. They do not modify them.

For the full rationale behind these patterns, the pitfalls of the old “bare metal and XAMPP” model, and how application repositories are expected to consume this platform, see the [`Golden path`](golden-path.md) write-up.

## Scope

This documentation is about platforming only.

It discusses the management of:

- GCP organisation level resources
- environment projects such as dev and prod
- shared Terraform state storage and encryption
- CI identities and their permissions
- GitHub organisation settings, core repositories, teams and branch protections

It does not manage:

- individual game or web workloads
- application specific infrastructure inside environment projects
- per project CI pipelines beyond what is needed for platform itself

Those concerns live in separate application or infrastructure repositories that consume the platform defined here.

## How to use these docs

- [Golden path](golden-path.md)

      Rationale for the platform, how it differs from legacy hosting patterns, and the core principles that guide everything else.

- [Architecture](architecture/index.md)

      High level view of the platform layout including GCP organisation structure, environment projects, Terraform backends and GitHub organisation wiring.

- [Runbooks](runbooks/index.md)

      Task oriented guides for common workflows such as bootstrapping the platform, adding a new environment or onboarding a new infra repository.

- [Contributing](contributing/index.md)

      Expectations and workflow for making changes to the platform platform, including review requirements and testing strategy.
