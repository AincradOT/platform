# Aincrad Platforming

This repository holds the platform foundations for both Google Cloud Platform and GitHub.

It defines:

- GCP organisation level layout and environment projects
- shared Terraform state backend and encryption
- CI service accounts and Workload Identity Federation for GitHub Actions
- GitHub organisation settings, core repositories, teams and branch protections

Application and service repositories consume these foundations. They do not modify them.

## Scope

This repository is for platform engineers.

It covers:

- GCP foundations under `cloud/`
- GitHub foundations under `github/`
- runbooks and design docs under `docs/` for MkDocs

It does not contain any workload specific infrastructure such as game servers or web stacks. Those live in their own repositories and use the foundations defined here.

## Prerequisites

Make sure you have the following installed:

- [Git](https://git-scm.com/downloads) – Version control system
- [Make](https://www.gnu.org/software/make/#download) – Build automation tool

Before running any Terraform in this repository you need:

- a GCP organisation and billing account
- a GitHub organisation where this repository lives
- Google Cloud SDK installed locally
- Terraform installed locally
- an account with organisation level permissions in GCP
- an owner in the GitHub organisation

The initial bootstrap also requires a personal access token or GitHub App token with rights to manage organisation settings, repositories and teams.

## Getting Started

Follow the [setup instructions](https://AincradOT.github.io/foundation/setup) for installation and environment configuration.

Quick start:

```bash
make help
```

## Documentation

Additional documentation is available on the repository documentation website:

- [Contributing Guide](https://AincradOT.github.io/foundation/contributing)
- [Architecture Overview](https://AincradOT.github.io/foundation/architecture)
