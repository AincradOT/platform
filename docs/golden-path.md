# Golden path for platform and application infrastructure (Open Tibia)

!!! note
    A Golden Path refers to an opinionated, well-documented, and supported way of building and deploying software within an organization. With a supported path, development teams are able to build more efficiently in ways that meet organizational standards. Golden Paths offer a clear approach for platform engineers to guide DevOps teams, AI/MLOps teams, security, networking or any other IT organization, ensuring consistency, reliability, and efficient use of time and resources.

## Audience and scope

This document describes the recommended way to structure:

* the platform foundations for Open Tibia services
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
* config drift between machines that nobody can fully explain
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

* GCP is used as a control plane for projects, state and secrets
* GitHub is the source of truth for code and CI pipelines
* Terraform defines infrastructure and can recreate environments
* Docker is used on VMs for services like the game server, database and web UI
* Ansible provisions those VMs consistently rather than hand written shell scripts that drift over time

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
* make onboarding a new engineer a documentation exercise, not archaeology

!!! note
    If you are building a short lived prototype, this is optional.
    If you expect your Open Tibia services to live longer than a hackathon, this is strongly recommended.

## Why GCP and GitHub for this golden path

There are three moving parts in this design:

* GitHub as the source of truth for code and CI
* Google Cloud Platform as the control plane for infrastructure
* Terraform as the orchestration tool between the two

GCP is not objectively better than AWS or Azure in all cases. It is a good fit here because:

* GCS is a simple and inexpensive Terraform state backend
* state locking and versioning are built in without extra components
* Secret Manager integrates cleanly with Terraform, CI and Ansible
* Workload Identity Federation with GitHub Actions avoids long lived service account keys
* the organisation and project model is relatively simple for small teams
* the idle cost of a minimal organisation, projects and state bucket is low

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

There is one repository for platform foundations, for example:

* `platform-foundation`

This repository contains two Terraform roots:

* `cloud` for GCP organisation, environment projects, state, secrets and CI identities
* `github` for GitHub organisation settings, core repositories, teams and branch protections

Application repositories depend on `platform-foundation`. They do not modify it.

### Remote state for everything except bootstrap

All non bootstrap Terraform roots use a shared GCS bucket for state.

* 0-bootstrap uses a local backend to create the bucket and KMS key.
* 1-org, 2-envs and all application roots use the GCS backend.
* Each root uses a unique prefix in the bucket to isolate state.

State is treated as an internal implementation detail, not something developers touch directly.

### Secrets are not in Terraform

Terraform does not own secret values.

* Terraform creates Secret Manager secrets and IAM bindings.
* Secret values are set via CLI or console, or injected at runtime by applications.
* Terraform configuration and state do not contain hardcoded passwords or API keys.

Ansible and applications read from Secret Manager when they need sensitive values.

### CI identities are short lived

CI pipelines authenticate to GCP and GitHub using:

* GitHub Actions OIDC tokens and Workload Identity Federation for GCP.
* GitHub Apps or fine grained tokens for GitHub itself.

No JSON service account keys are committed to repositories or stored as permanent secrets.

## Golden path architecture

At a high level the golden path looks like this.

### Platform layer

A single platform repository contains the following logical components.

**`cloud` component**

* creates a bootstrap project
* creates the GCS state bucket with versioning and encryption
* creates environment projects such as `env-dev` and `env-prod`
* defines service accounts and Workload Identity Federation for CI

**`github` component**

* configures GitHub organisation settings
* creates core repositories such as `platform-foundation`, `game-infra`, `game-server`, `web-ui`
* defines teams and their permissions
* enforces branch protection on main and production branches

The platform layer is applied rarely. It changes when the organisation shape changes, not every week.

### Application layer

Each application or service has its own repository, for example:

* `game-infra`
* `game-server`
* `web-ui`

Each repository:

* uses the shared GCS bucket as its Terraform backend
* targets one or more environment projects created by the platform layer
* uses GitHub Actions with Workload Identity Federation to assume the correct service account for each environment
* reads secrets from Secret Manager via Ansible or application code

Application layer repositories are where day to day infrastructure changes happen.

## Responsibilities of the platform repository

The platform repository handles:

* GCP organisation level setup that must exist before anything else
* the bootstrap project, state bucket and KMS key
* environment projects for dev and prod
* CI service accounts and their IAM bindings
* Workload Identity Federation configuration for GitHub Actions
* GitHub organisation level settings
* core repositories and mandatory branch protections
* teams and their permissions on core repositories

It does not create application specific infrastructure such as game server VMs, databases or load balancers. Those belong to application repositories.

The platform repository is expected to be stable and boring. Changes should be careful, reviewed and infrequent.

## Responsibilities of application and service repositories

Each application or service repository is responsible for:

* its own Terraform root modules inside the environment projects
* the Ansible playbooks or configuration management needed on its VMs
* its own CI workflows for plan and apply
* its own runtime monitoring and alerting configuration

These repositories do not:

* create or destroy GCP organisations or environment projects
* change the shared state bucket or KMS key
* change GitHub organisation level settings or core teams

They consume the boundaries defined by the platform and work within them.

## CI and deployment flow on the golden path

A typical deployment flow for an application repository looks like this.

1. A change is made to Terraform or Ansible in the infra repository.
2. A pull request is opened.
3. GitHub Actions runs `terraform init` with the GCS backend and `terraform plan` against the appropriate environment project.
4. The plan is reviewed and the pull request is merged.
5. GitHub Actions on `main` requests an OIDC token, uses Workload Identity Federation to assume the environment service account, and runs `terraform apply` against the same state and project.

For configuration management:

* Ansible runs either in CI or from a trusted controller machine.
* Ansible uses a GCP identity to read secrets from Secret Manager.
* Ansible provisions Docker, systemd units and configuration files on the target VMs.

Runtime changes are driven by code changes, not ad hoc console changes.

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
* GCP and GitHub are wired together using Terraform, Secret Manager, GCS state and Workload Identity Federation
* secrets are never hardcoded in Terraform or Ansible inventories
* CI identities are short lived and narrowly scoped
* the old model of hand built servers, manual scripts and weak release engineering is explicitly rejected

If you are about to add a new environment, a new application repository or a new kind of CI workflow, check here first and decide whether you are following this golden path or deviating from it on purpose.
