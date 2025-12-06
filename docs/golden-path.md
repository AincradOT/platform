# Golden path for platform and application infrastructure (Open Tibia)

!!! note
    A Golden Path refers to an opinionated, well-documented, and supported way of building and deploying software within an organization.
    With a supported path, development teams are able to build more efficiently in ways that meet organizational standards.
    Golden Paths offer a clear approach for platform engineers to guide DevOps teams, AI/MLOps teams, security, networking or any other IT organization, ensuring consistency, reliability, and efficient use of time and resources.

## Audience and scope

This document describes the recommended way to structure:

* the platform platform for Open Tibia services
* the application and service infrastructure that runs on top

The goal is to give a clear, opinionated path that:

* works for a solo developer today
* scales to multiple services and developers later
* stays cheap and understandable

You can run an Open Tibia server without following this golden path. You should understand what you give up if you do.

## From legacy hosting to a modern golden path

Historically, Open Tibia servers were hosted in a very different way.

Typical pattern:

* rent a bare metal server or a cheap VPS
* install XAMPP or a hand assembled stack
* run MySQL and PHPMyAdmin directly on the host
* drop the game server, website and tools onto the same machine
* glue everything together with SSH, shell scripts and tribal knowledge

To test or develop new code you often had two bad options:

* make changes directly on the live server and hope nothing breaks
* clone the entire stack by hand and try to keep a second server up to date

Common failure modes:

* no clear separation between dev and prod
* [config drift](architecture/state-management.md) between machines that nobody can fully explain
* upgrades that break because there is no consistent release process
* no real way to hand the project over if the original owner disappears
* no documentation of how the platform is put together

This model worked when expectations were low and the community tolerated downtime and breakage. It does not match modern expectations for stability, repeatability and collaboration.

The golden path in this repository is a deliberate move away from that legacy model.

It aims to fix the core problems:

* environments are defined as code and can be recreated
* state and secrets are centralised rather than scattered across VMs
* CI pipelines replace manual SSH sessions for deployments
* release engineering is explicit instead of copying files by hand
* ownership of the platform is not tied to a single person’s memory

The goal is not perfection. The goal is to avoid the well known traps that have held back a lot of Open Tibia hosting.

## Cloud native influence

The intent is not to jump straight to a full Kubernetes cluster with every CNCF project in the landscape. That would be overkill and expensive for most Open Tibia projects.

The golden path borrows specific ideas from the cloud native world that are worth adopting even for a single game server:

* infrastructure as code instead of click configuring VMs
* declarative environments instead of one off stacks
* repeatable deployments instead of manual edits on live systems
* clear separation between platform and application concerns
* short lived CI identities instead of long lived shared credentials

In concrete terms here this means:

* GCP is used as a control plane for projects, [state](architecture/state-management.md) and [secrets](https://cloud.google.com/secret-manager/docs)
* GitHub is the source of truth for code and CI pipelines
* [Terraform](https://www.terraform.io/docs) defines infrastructure and can recreate environments
* [Docker](https://docs.docker.com/) is used on VMs for services like the game server, database and web UI
* [Ansible](https://docs.ansible.com/) provisions those VMs consistently rather than hand written shell scripts that drift over time

The golden path is a pragmatic subset of cloud native ideas. You get better reliability and repeatability without needing the full complexity and cost of Kubernetes.

## Why have a platform at all

You can run a game server or a web app with none of this in place.

You can:

* click create project and bucket in a cloud console
* point Terraform at a local state file
* manage GitHub teams and branches through the UI
* copy and paste CI pipelines between repositories

This works while:

* there is one environment
* there is one repo
* there is one developer

It breaks down as soon as you introduce:

* dev and prod environments with different risk profiles
* multiple repositories that must follow the same patterns
* more than one person touching infrastructure
* a desire to hand the project over or bring new contributors in smoothly

The platform layer exists to:

* centralise the organisation level decisions
* give a single source of truth for environments and state
* avoid every repo reinventing state backends, secrets and CI auth
* maintain a consistent and well-documented infrastructure that can be managed by a single engineer

!!! note
    If you are building a short lived prototype, this is optional.
    If you expect your Open Tibia services to live longer than a hackathon, this is strongly recommended.

## Why GCP and GitHub for this golden path

There are three moving parts in this design:

* GitHub as the source of truth for code and CI
* Google Cloud Platform as the control plane for infrastructure
* Terraform as the orchestration tool between the two

GCP is not objectively better than AWS or Azure in all cases. It is a good fit here because:

* GCS provides inexpensive Terraform state storage with built-in versioning
* State versioning is built-in; state locking requires coordination (acceptable for sequential small team workflows)
* Secret Manager integrates cleanly with Terraform, CI and Ansible
* Service account keys for CI are simpler than Workload Identity Federation for small teams
* The organisation and project model is relatively simple for small teams
* The idle cost of a minimal organisation, projects and state bucket is low

GitHub is used because:

* it already hosts most Open Tibia code and tooling
* GitHub Actions provides OIDC tokens that integrate well with GCP
* the GitHub provider for Terraform lets the organisation layout be managed as code

If you ever migrate to another cloud, most of the principles in this document still apply. Only the provider specific pieces need to change.

## Core principles

These principles drive the rest of the design.

### Separation of concerns

Platform responsibilities and project responsibilities are kept separate.

* The platform layer owns the organisation shape, shared state and CI identities.
* Application and service repositories own their own infrastructure inside the boundaries the platform defines.

This reduces blast radius and stops every repo from becoming a second platform implementation.

### Single platform repository

There is one repository for platform infrastructure, for example:

* `platform`

This repository contains Terraform roots organized by lifecycle:

* `0-bootstrap` - Creates bootstrap project and GCS state bucket (local backend initially)
* `1-org` - Creates organizational folders and shared services project
* `2-environments` - Creates dev and production environment projects
* (optional) `github` - GitHub organisation settings, core repositories, teams and branch protections

Application repositories depend on the platform repository. They do not modify it.

### Remote state for everything except bootstrap

All non bootstrap Terraform roots use a shared GCS bucket for state.

* 0-bootstrap uses a local backend to create the bucket.
* 1-org, 2-environments and all application roots use the GCS backend.
* Each root uses a unique prefix in the bucket to isolate state.

State is treated as an internal implementation detail, not something developers touch directly. Access is restricted to org administrators who run terraform.

### Secrets are not in Terraform

[Terraform](https://www.terraform.io/docs) does not own secret values.

* Terraform creates [Secret Manager](https://cloud.google.com/secret-manager/docs) resources and [IAM bindings](https://cloud.google.com/iam/docs/overview).
* Secret values (API keys, database passwords, tokens) are set via [gcloud CLI](https://cloud.google.com/sdk/gcloud) or injected at runtime.
* Terraform configuration and [state](architecture/state-management.md) never contain hardcoded secrets.

Applications and configuration management tools read from Secret Manager at runtime when they need sensitive values.

**Why Secret Manager:** Provides versioned, encrypted storage for application secrets with fine-grained IAM control. Secrets are encrypted at rest automatically (no [KMS](https://cloud.google.com/kms/docs) required). Cost is ~$0.06/month per secret, negligible for small teams. Alternative of environment variables or config files is error-prone and insecure.

### CI identities use scoped credentials

[CI pipelines](architecture/ci.md) authenticate using:

* Organization-scoped [GitHub App](https://docs.github.com/en/apps) with permissions across all repositories.
* [Service account](https://cloud.google.com/iam/docs/service-accounts) keys stored as organization-level [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) (rotated quarterly).

For small teams managing multiple services (10+ repositories), org-scoped credentials are more practical than per-repository credentials. The operational overhead of maintaining individual apps per repo outweighs the marginal security benefit when:

* All repositories are within the same trust boundary (same team, same organization)
* The service account permissions are already scoped to specific GCP projects (dev vs prod)
* The GitHub org has [branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches) preventing unauthorized merges

This approach is simpler than [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) and adequate for teams without compliance requirements. As the team grows beyond 20 developers or adds compliance requirements, migration to Workload Identity Federation can be considered.

!!! note
    No credentials are committed to repositories.
    All secrets are stored in GitHub encrypted secrets or GCP Secret Manager.

### Portability and lift-and-shift

This platform design is deliberately portable and forkable:

* All GCP-specific identifiers (org ID, project IDs, bucket names) are variables, not hardcoded
* No vendor lock-in to proprietary services ([GCS](https://cloud.google.com/storage/docs) and Secret Manager have drop-in replacements on other clouds)
* [Terraform state](architecture/state-management.md) can be migrated to different backends ([S3](https://www.terraform.io/docs/language/settings/backends/s3.html), [Azure Storage](https://www.terraform.io/docs/language/settings/backends/azurerm.html), [Terraform Cloud](https://www.terraform.io/cloud)) with minimal changes
* The folder structure and separation of concerns transfers directly to AWS (replace folders with [OUs](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html)) or Azure (replace with [management groups](https://docs.microsoft.com/en-us/azure/governance/management-groups/))

The entire platform can be forked, re-parameterized, and deployed to a new organization in 2-3 hours. This makes the pattern:

* Easy to replicate for multiple Open Tibia communities
* Recoverable if starting fresh after a catastrophic failure
* Transferable if ownership changes hands

!!! warning
    When forking, update all variables in terraform.tfvars files.
    Never commit real org IDs, project IDs, or bucket names to public repositories.

### Additional architecture details

For implementation specifics, see:

* [State Management](architecture/state-management.md) - State bucket IAM, versioning, locking strategy, and recovery procedures
* [Disaster Recovery](architecture/disaster-recovery.md) - Platform DR procedures, backup strategies, and rebuild runbooks  
* [Cost Model](architecture/cost-model.md) - GCP cost estimates and optimization strategies for budget-conscious teams

## Golden path architecture

At a high level the golden path looks like this.

### Platform layer

A single platform repository contains the following logical components.

**GCP platform component (current implementation)**

* creates a bootstrap project for platform administration
* creates the [GCS state bucket](architecture/state-management.md) with [versioning](https://cloud.google.com/storage/docs/object-versioning) for terraform state
* creates [organizational folders](https://cloud.google.com/resource-manager/docs/creating-managing-folders) (shared, dev, prod)
* creates environment [projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects) and shared services project
* attaches projects to central logging metrics scope

**Already implemented:**

* [Service accounts](https://cloud.google.com/iam/docs/service-accounts) for terraform CI operations with appropriate IAM bindings
* [Secret Manager API](https://cloud.google.com/secret-manager/docs) enabled in environment projects (applications create their own secrets)

**GitHub organization component** (optional, can be managed manually)

* configures GitHub organisation settings as a one-time bootstrap
* creates core repository structure
* defines teams and their base permissions
* sets up branch protection rules

For small teams, this can be a one-time terraform apply with drift ignored, or managed entirely via GitHub UI.

The platform layer is applied rarely. It changes when the organisation shape changes, not every week.

### Application layer

Each application or service has its own repository with its own infrastructure code, for example:

* `game-infra` - VM infrastructure, networking, load balancers for game servers
* `game-server` - application deployment, configuration management
* `web-ui` - web application infrastructure and deployment

Each repository:

* contains its own Terraform roots for infrastructure within the environment projects
* uses the shared GCS bucket as its Terraform backend (with unique prefix per repo)
* targets the appropriate environment project (dev or prod) created by the platform
* uses GitHub Actions with service account credentials to run terraform
* reads application secrets from Secret Manager

This separation keeps platform concerns (org structure, projects, state backend) separate from application concerns (VMs, databases, deployments). Application own their infrastructure within the boundaries the platform defines.

## Responsibilities of the platform repository

The platform repository handles:

* GCP organisation level setup that must exist before anything else
* the bootstrap project and state bucket
* organizational folders (shared, dev, prod)
* environment projects and shared services project
* Secret Manager API enablement (applications create their own secret resources)
* CI service accounts and their IAM bindings
* (optionally) GitHub organisation level settings as one-time bootstrap

It does not create application specific infrastructure such as game server VMs, databases or load balancers. Those belong to application repositories.

The platform repository is expected to be stable and boring. Changes should be careful, reviewed and infrequent.

## Responsibilities of application and service repositories

Each application or service repository is responsible for:

* its own Terraform root modules inside the environment projects
* the Ansible playbooks or configuration management needed on its VMs
* its own CI workflows for plan and apply
* its own runtime monitoring and alerting configuration

These repositories do not:

* create or destroy GCP organisations, folders, or environment projects
* change the shared state bucket configuration
* modify platform-level IAM or service accounts

They consume the boundaries defined by the platform and work within them.

## CI and deployment flow on the golden path

A typical deployment flow for an application repository looks like this.

1. A change is made to Terraform in the application infrastructure repository.
2. A pull request is opened.
3. GitHub Actions authenticates using a service account key (stored as GitHub encrypted secret).
4. The workflow runs `terraform init` with the GCS backend and `terraform plan` against the appropriate environment project.
5. The plan output is posted as a comment on the PR for review.
6. After review and merge to `main`, GitHub Actions runs `terraform apply` to deploy changes.
7. Applications read secrets from Secret Manager at runtime using their service account identity.

**Configuration management** (if needed for VMs) lives in the same application repository and uses the same CI identity to provision infrastructure.

Runtime changes are driven by code changes, not manual console changes.

## When you can deviate from the golden path

You can deviate from this path if:

  - you are building a short lived spike or proof of concept
  - you are testing a completely different stack that may never live in production
  - you are experimenting with new platform patterns that are not ready to be codified

You should not deviate when:

  - you are adding another production like environment
  - you are creating a new long lived service
  - you are changing how state, secrets or CI auth work

The more exceptions you create, the weaker the platform becomes. Deviations should be temporary and deliberately closed off or moved into the platform once proven.

## Summary

This golden path is not mandatory for writing code. It is mandatory if you want Open Tibia infrastructure to remain understandable and operable as it grows.

Key points:

* a single platform repository defines the organisation skeleton and cross cutting concerns
* application repositories consume that skeleton and own their own runtime infrastructure
* GCP and GitHub are wired together using Terraform, GCS state and service account authentication
* secrets are never hardcoded in Terraform or Ansible inventories
* CI identities use service account keys (rotated quarterly) scoped to specific projects
* the old model of hand built servers, manual scripts and weak release engineering is explicitly rejected

If you are about to add a new environment, a new application repository or a new kind of CI workflow, check here first and decide whether you are following this golden path or deviating from it on purpose.
