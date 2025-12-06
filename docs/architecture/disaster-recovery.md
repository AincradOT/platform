# Disaster Recovery

## Scope

This document covers disaster recovery for the **platform layer** only:

- GCP organization structure (folders, projects)
- Terraform state bucket
- Secret Manager resources
- Platform-level IAM

Application-specific DR (databases, VMs, application data) is the responsibility of application repositories.

## Threat Model

### What we're protecting against

- Accidental deletion of state bucket
- Corrupted terraform state
- Accidental destruction of platform resources
- Loss of access to GCP organization

### What we're NOT protecting against

- GCP region failure (not using multi-region for cost reasons)
- Complete GCP account compromise (requires manual recovery via Google support)

## State Bucket Protection

### Prevention

1. [Versioning](https://cloud.google.com/storage/docs/object-versioning) is enabled to keep the last 50 versions of each state file
2. Lifecycle rule `prevent_destroy = true` in terraform prevents accidental deletion
3. IAM restrictions ensure only org administrators can modify bucket
4. Public access prevention is enforced via `public_access_prevention = "enforced"`

### Recovery from state corruption

```bash
# List available versions
gsutil ls -a gs://sao-tfstate/terraform/org/default.tfstate

# Restore specific version
gsutil cp gs://sao-tfstate/terraform/org/default.tfstate#<version> \
          gs://sao-tfstate/terraform/org/default.tfstate
```

!!! note
    [`gsutil`](https://cloud.google.com/storage/docs/gsutil) is part of the Cloud SDK.

### Recovery from state bucket deletion

If the bucket is deleted (despite prevent_destroy):

1. Check GCS trash/soft delete for 30 day retention if enabled
2. Recreate bucket manually via console
3. Re-run `0-bootstrap` terraform to restore bucket configuration
4. Restore state files from local backups if terraform was run locally recently
5. In worst case, rebuild state via [`terraform import`](https://www.terraform.io/docs/cli/import/index.html) for all resources

## Secret Manager Recovery

Secret Manager keeps all versions of secrets. Accidentally overwritten secrets can be restored.

```bash
# List secret versions
gcloud secrets versions list secret-name --project=sao-shared-logging

# Access previous version
gcloud secrets versions access <version> --secret=secret-name
```

!!! note
    Use [`gcloud secrets`](https://cloud.google.com/sdk/gcloud/reference/secrets) commands to manage Secret Manager.

### If Secret Manager resource is deleted

Re-create via terraform, then manually re-populate secret values (terraform creates the container, not the value).

## Project and Folder Recovery

### Prevention

- Production projects have `deletion_policy = "PREVENT"` (requires manual unlinking from billing before deletion)
- Folders cannot be deleted if they contain projects

### Recovery

- GCP has a 30-day soft delete period for projects
- Deleted projects can be restored via console or API within 30 days
- After 30 days, project IDs are permanently released

```bash
# List deleted projects
gcloud projects list --filter="lifecycleState:DELETE_REQUESTED"

# Restore deleted project
gcloud projects undelete <project-id>
```

## Organization-Level IAM

### Backup

Export IAM policy regularly:

```bash
gcloud organizations get-iam-policy <org-id> > org-iam-backup.json
```

Store this backup outside GCP (GitHub private repo, local encrypted storage).

### Recovery

Re-apply from backup:

```bash
gcloud organizations set-iam-policy <org-id> org-iam-backup.json
```

## Runbook: Complete Platform Rebuild

If everything is lost (state, projects, bucket), here's the recovery order:

1. Verify org and billing still exist (these cannot be terraform-managed)
2. Re-run 0-bootstrap to create new state bucket and bootstrap project
3. Import or rebuild 1-org resources (folders, shared services project, or recreate from scratch if necessary)
4. Import or rebuild 2-environments projects
5. Re-populate Secret Manager (values must be re-entered manually)
6. Notify application teams to verify their state and infrastructure

!!! note
    Time estimate: 2-4 hours for platform rebuild, assuming no application data loss.

## Testing DR Procedures

### Quarterly drill

1. Restore a previous state version in a test scenario
2. Verify terraform plan shows no unexpected changes
3. Document any issues encountered

### Annual drill

1. Create a test organization
2. Run full bootstrap process from documentation
3. Verify documentation is accurate and complete

## Backup Responsibilities

### Platform team

- Maintain state bucket versioning
- Export org IAM policy monthly
- Keep local copies of terraform state from recent applies

### Application teams

- Responsible for their own application data backups
- Database backups should go to GCS (cheap, reliable)
- Document their own application-specific DR procedures
