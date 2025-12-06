# GCP platform

This section describes how we use GCP as the control plane for cloud resources, Terraform state and secrets.

## Scope

The GCP platform Terraform is organized into separate roots in the `platform` repository:

- `0-bootstrap` creates the bootstrap project and GCS state bucket
- `1-org` creates organizational folders and shared services project
- `2-environments` creates dev and prod environment projects

These manage:

- GCP organisation folders (shared, dev, prod)
- Bootstrap project for state storage
- GCS bucket for Terraform state with versioning
- Environment projects for dev and prod
- Shared services project for logging
- Service accounts for CI operations
- Secret Manager API enablement (applications create their own secrets)

It does **not** manage individual workloads such as game servers or web applications. Those live in separate repositories and projects.

## State backend

[Terraform state](https://www.terraform.io/docs/language/state/index.html) uses the [GCS backend](https://www.terraform.io/docs/language/settings/backends/gcs.html).

Example backend block for a project repository:

```hcl
terraform {
  backend "gcs" {
    bucket = "tf-state-platform-001"
    prefix = "game-infra/prod"
  }
}
```

Key points:

- The bucket is created in the `0-bootstrap` root
- Bucket versioning is enabled for state change history
- Access restricted to org administrators and CI service accounts
- [GCS does not provide native state locking](state-management.md#state-locking), acceptable for small teams running sequentially

Each Terraform root uses a distinct `prefix` so state files are isolated and blast radius is small.

## Environment projects

We use a three-tier environment layout:

- Bootstrap project for state bucket and platform administration
- Shared services project for logging, monitoring, and Secret Manager
- Dev project for development workloads
- Prod project for production workloads

Example naming: `sao-bootstrap`, `sao-shared-logging`, `sao-dev`, `sao-prod`

Projects are created by the platform Terraform roots. Application repositories receive the project IDs as inputs and never create projects themselves.

## Service accounts and roles

The GCP platform will define service accounts for CI operations (Phase 2):

- Platform CI service account for Terraform operations on org and projects
- Dev CI service account for development environment operations
- Prod CI service account for production environment operations

Service accounts are granted only the roles they need. For example:

- Platform CI service account has org-level permissions for folder and project management
- Dev CI service account has permissions only within dev project
- Prod CI service account has permissions only within prod project
- All CI service accounts have read/write access to state bucket with appropriate prefixes

## CI authentication approach

For small teams, we use service account keys stored as GitHub encrypted secrets:

- Keys are generated manually via gcloud CLI
- Stored as organization-level GitHub encrypted secrets
- Rotated quarterly as part of security maintenance
- Branch protection rules enforce which branches can deploy to production

!!! note
    Workload Identity Federation can be added later as team size or compliance requirements grow.
    Current approach prioritizes operational simplicity over marginal security gains for small trusted teams.

## Secrets and Secret Manager

[Secret Manager](https://cloud.google.com/secret-manager/docs) provides versioned, encrypted storage for application secrets (API keys, database passwords, tokens).

The GCP platform enables the Secret Manager API in environment projects. **Applications are responsible for**:

- Creating their own Secret Manager resources with application-specific names
- Configuring IAM bindings for service account access
- Setting up replication policies
- Managing secret lifecycle (creation, rotation, deletion)

Secret values are never stored in Terraform. They are set via:

- `gcloud secrets versions add` for manual updates
- Application injection at runtime

Applications read secrets at runtime using their service account identity.

See [State Management](state-management.md) for details on secrets handling.
