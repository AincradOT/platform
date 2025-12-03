# Platform foundation

This section describes how we the architecture and how we manage platform responsibilities for both Google Cloud Platform (GCP) and GitHub.

The goal is to:

- keep organisation and platform concerns out of individual application repositories
- make bootstrap and day to day operations reproducible and low friction
- stay cheap to run while still following sane patterns

The platform has two main pillars:

- **GCP foundation** for organisation, projects, state, secrets and CI identities
- **GitHub foundation** for organisation settings, core repositories, teams and branch protections

Application and service repositories consume these foundations but do not modify them.

If you have not read the [Golden path](../golden-path.md) yet, start there. It explains the rationale and the problems this platform is designed to solve.

## What this section covers

The architecture documentation focuses on:

- how the platform is structured across GCP and GitHub
- which repository owns which responsibilities
- how Terraform, Ansible, Docker and CI fit together
- where state and secrets live
- how CI identities are created and consumed

This is not a full tutorial for Terraform, GCP or GitHub. It assumes you are comfortable reading infrastructure as code and want to understand how this specific platform hangs together.

## How the pieces fit together

At a high level the platform is made up of:

- a single platform repository that owns organisation level decisions
- one or more environment projects in GCP for dev, prod and similar stages
- a shared Terraform state bucket with clear prefixes per root module
- GitHub organisation settings and teams defined as code
- CI identities and Workload Identity Federation linking GitHub Actions to GCP
- application and service repositories that live inside the boundaries this platform creates

The architecture pages walk through each of these layers so a new engineer can answer questions such as:

- where a given resource should live
- which repository owns a given concern
- how a change flows from pull request to applied infrastructure
- how secrets and state are accessed in a safe way

## When to read this

You should read this section when you:

- are onboarding as a new engineer and want a mental model for the platform
- are about to change the platform repository itself
- are creating a new application or service repository and want to align with the existing patterns
- are debugging a problem that crosses GCP, GitHub and CI boundaries

If you are only changing application code and not touching infrastructure, you rarely need to read this section in full.

## Sections

- [Overview](index.md)

      High level summary of platform responsibilities and how they are split between GCP and GitHub.

- [Platforming](platforming.md)

      Detailed view of platform responsibilities, repository layout and the separation between platform and application concerns.

- [Google Cloud](gcp.md)

      GCP organisation and project structure, Terraform roots, state backend layout, service accounts and environment projects.

- [GitHub Organisation](github.md)

      GitHub organisation settings, core repositories, team structure and branch protection rules.

- [Continuous Integration](ci.md)

      CI patterns for Terraform and Ansible, use of GitHub Actions, Workload Identity Federation and how plans and applies are run per environment.

- [Secrets and state management](state.md)

      Terraform state layout in GCS, use of Secret Manager, integration points with CI and Ansible, and rules for how secrets are handled across the platform.
