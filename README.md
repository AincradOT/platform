# Aincrad Platforming

This repository holds the platform foundations for both Google Cloud Platform and the GitHub organisation.

It defines:

- GCP organisation level layout and environment projects
- Shared Terraform state backend and encryption
- CI service accounts and Workload Identity Federation for GitHub Actions
- GitHub organisation settings, core repositories, teams and branch protections

Application and service repositories consume these foundations. They do not modify them.

For the full rationale behind these patterns, the pitfalls of the old “bare metal and XAMPP” model, and how application repositories are expected to consume this platform, see the [`Golden path`](https://aincradot.github.io/foundations/golden-path) write-up.

## Scope

This repository is about platforming only.

It manages:

- GCP organisation level resources
- environment projects such as dev and prod
- shared Terraform state storage and encryption
- CI identities and their permissions
- GitHub organisation settings, core repositories, teams and branch protections

It does not manage:

- individual game or web workloads
- application specific infrastructure inside environment projects
- per project CI pipelines beyond what is needed for platform itself

Those concerns live in separate application or infrastructure repositories that consume the foundations defined here.

## Prerequisites

Make sure you have the following installed:

- [Git](https://git-scm.com/downloads) - Version control system
- [Make](https://www.gnu.org/software/make/#download) - Build automation tool

Before running any Terraform in this repository you need:

- a GCP organisation and billing account
- a GitHub organisation where this repository lives
- Google Cloud SDK installed locally
- Terraform installed locally
- an account with organisation level permissions in GCP
- an owner in the GitHub organisation

The initial bootstrap also requires a personal access token or GitHub App token with rights to manage organisation settings, repositories and teams.

## Documentation

Additional documentation is available on the repository documentation website:

- [Contributing Guide](https://aincradot.github.io/foundations/contributing)
- [Architecture Overview](https://aincradot.github.io/foundations/architecture)
