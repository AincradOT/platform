# Terraform State Management

[Terraform state](https://www.terraform.io/docs/language/state/index.html) is stored in a [GCS bucket](https://cloud.google.com/storage/docs) with [versioning](https://cloud.google.com/storage/docs/object-versioning) enabled by the bootstrap process. All terraform roots (except bootstrap itself initially) use this bucket with unique prefixes for state isolation.

## Overview

Terraform state is stored in a single GCS bucket created by the bootstrap process. All terraform roots (except bootstrap itself initially) use this bucket with unique prefixes for state isolation.

## State Bucket Configuration

### Bucket features

- [Versioning](https://cloud.google.com/storage/docs/object-versioning) enabled (retains last 50 versions)
- [Uniform bucket-level access](https://cloud.google.com/storage/docs/uniform-bucket-level-access) (UBLA)
- [Public access prevention](https://cloud.google.com/storage/docs/public-access-prevention) enforced
- Google-managed encryption at rest

!!! note
    No KMS encryption is used for the state bucket.
    GCS provides encryption at rest by default.
    Customer-managed encryption keys (CMEK) add cost and complexity without meaningful security benefit for this use case.

## Access Control

### Who can access state

- Organization administrators who run terraform (read/write)
- Service accounts used by CI (read/write on their prefixes)

!!! warning
    State bucket access is restricted to terraform operators only.
    Developers work via terraform plan/apply, not by reading state directly.

### IAM bindings

```
roles/storage.objectAdmin - terraform service accounts
roles/storage.objectViewer - (optional) audit/monitoring tools
```

## State Prefixes

Each terraform root uses a unique prefix in the bucket:

```
gs://sao-tfstate/
├── terraform/bootstrap/           # bootstrap state
├── terraform/org/                 # organizational structure state
├── terraform/environments/dev/    # development environment
├── terraform/environments/prod/   # production environment
└── terraform/apps/{repo-name}/    # application infrastructure repos
```

Application repositories use their repository name as part of the prefix to avoid conflicts.

## State Locking

!!! warning
    GCS does not provide native state locking.
    For small teams (3-10 developers) running terraform sequentially, this is acceptable.

### Mitigation

- Coordinate terraform runs (don't run concurrent applies)
- Use CI to serialize applies (GitHub Actions runs sequentially per repo)
- Monitor for state corruption (versioning allows rollback)

### If locking becomes necessary

Consider Terraform Cloud (free tier) or AWS S3 - however that requires an additional platform to manage.

## Bootstrap State Migration

The bootstrap process itself uses a two-phase state approach:

1. The initial apply uses local state (terraform.tfstate in 0-bootstrap directory)
2. After the bucket exists, migrate bootstrap state to GCS using `terraform init -migrate-state`

!!! note
    This solves the chicken-and-egg problem: the bucket must exist before it can store state, but terraform needs state to manage the bucket.

## Secret Manager as canonical store

[GCP Secret Manager](https://cloud.google.com/secret-manager/docs) stores all sensitive values that need to be consumed by applications, Ansible or CI.

## State Security

### State files contain sensitive information

- Resource IDs and configurations
- Service account emails
- IAM bindings

### Best practices

- Restrict bucket access to org administrators only
- Enable versioning for recovery
- Never commit local state files to git (.tfstate files are gitignored)
- Rotate service account keys periodically if stored in state

!!! danger
    State should NOT contain secret values (passwords, API keys, tokens).
    These should be in Secret Manager, referenced by ID only.

## Recovery

If state is corrupted or lost:

1. Use GCS versioning to restore a previous version
   ```bash
   gsutil cp gs://sao-tfstate/terraform/org/default.tfstate#<version> gs://sao-tfstate/terraform/org/default.tfstate
   ```

2. If no good version exists, rebuild state via `terraform import`

3. In worst case where the bucket is deleted, restore from local backups or recreate infrastructure

!!! note
    The state bucket has `prevent_destroy` lifecycle rule in terraform to prevent accidental deletion.
