# GCP platform

This section describes how we use GCP as the control plane for cloud resources, Terraform state and secrets.

## Scope

The GCP platform Terraform root is located under `cloud/` in the `platform` repository. It manages:

- enabling the GCP organisation for Terraform usage
- a bootstrap project for shared services
- a GCS bucket for Terraform state with versioning
- a KMS key for encrypting state and secrets
- environment projects for `dev` and `prod`
- service accounts for CI and Ansible
- Workload Identity Federation (WIF) configuration for GitHub Actions

It does **not** manage individual workloads such as game servers or web applications. Those live in separate repositories and projects.

## State backend

Terraform state uses the GCS backend.

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

- The bucket is created and configured in the platform `cloud/` root.
- Bucket versioning is enabled so there is a history of state changes.
- Access to the bucket is restricted to platform engineers and CI service accounts.
- Locking is handled by GCS generation preconditions and does not require a separate lock table.

Each Terraform root uses a distinct `prefix` so state files are isolated and blast radius is small.

## Environment projects

We use a simple environment layout:

- `platform-bootstrap` project for state, KMS and CI service accounts
- `env-dev` project for development workloads
- `env-prod` project for production workloads

The exact naming convention can be adjusted but should be consistent across all stacks.

Projects are created and managed by the `cloud/` Terraform root. Application repositories receive the project IDs as inputs and never create projects themselves.

## Service accounts and roles

The GCP platform defines a small set of service accounts:

- platform CI service account for Terraform operations on platform resources
- project CI service account per environment project
- optional Ansible controller service account if Ansible pulls secrets directly from GCP

Service accounts are granted only the roles they need. For example:

- platform CI service account:
  - read and write on the state bucket
  - organisation level roles required by the platform
- project CI service account:
  - compute, storage and other roles within its environment project only
  - no organisation level permissions

## Workload Identity Federation for GitHub Actions

We use Workload Identity Federation to allow GitHub Actions jobs to impersonate service accounts without storing JSON keys.

The platform `cloud/` root creates:

- a Workload Identity Pool for GitHub
- a Workload Identity Provider that trusts `https://token.actions.githubusercontent.com`
- attribute mappings for `repository` and `ref`
- bindings that allow specific GitHub repositories to impersonate specific service accounts

Example binding pattern:

- repository `org/game-infra` on branch `main` can impersonate the `env-prod` project CI service account
- repository `org/game-infra` on branch `develop` can impersonate the `env-dev` project CI service account

This makes it clear which repository and branch is allowed to manage which environment.

## Secrets and Secret Manager

Secret Manager is the canonical store for secrets that need to be consumed by applications, Ansible or CI.

The GCP platform Terraform root is responsible for:

- creating secrets with stable names
- configuring replication and labels
- granting read access to the appropriate service accounts

We deliberately avoid storing secret values directly in Terraform configuration or state. Secret values are set via CLI or console by trusted humans or by one off scripts outside of normal Terraform runs.

Application repositories read secrets at runtime using:

- Ansible lookup plugins when provisioning VMs
- application code or entrypoints that call Secret Manager
- CI jobs when they need to pass secrets into templated manifests

There is a separate document that covers secrets and state in more detail.
