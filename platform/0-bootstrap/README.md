# 0-bootstrap

Creates the GCP bootstrap project and GCS bucket for Terraform state.

## Prerequisites

1. Verify `gcloud` is installed:
   ```bash
   gcloud version
   ```

2. Authenticate and initialize gcloud:
   ```bash
   gcloud init
   ```
   Select your organization account when prompted.

3. Get your organization ID:
   ```bash
   gcloud organizations list
   ```

4. Get your billing account ID:
   ```bash
   gcloud billing accounts list
   ```

## Additional Resources

- [GCS Bucket Versioning](https://cloud.google.com/storage/docs/object-versioning) - Understanding state versioning
- [Terraform State Management](https://developer.hashicorp.com/terraform/language/state) - State concepts and best practices
- [GCS Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) - Backend setup details
- [GCP Project Creation](https://cloud.google.com/resource-manager/docs/creating-managing-projects) - Project lifecycle management

!!! note
    For step-by-step bootstrap instructions, see the [Platform README](../README.md).
    This document provides reference information for the 0-bootstrap terraform root.

## Configuration

Create `terraform.tfvars` with your values:

```hcl
org_id              = "123456789012"
billing_account_id  = "ABCDEF-123456-ABCDEF"
project_name        = "yourorg"
state_bucket_name   = "yourorg-tfstate"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `org_id` | GCP organization ID | Yes |
| `billing_account_id` | Billing account ID | Yes |
| `project_name` | Project name (e.g. `aincrad` generates project ID `aincrad-bootstrap`) | Yes |
| `state_bucket_name` | GCS bucket name for state | Yes |
| `location` | GCS bucket location (single region for cost optimization) | No (default: `europe-west3`) |
| `labels` | Resource labels | No |

## Outputs

- `bootstrap_project_id`: The created project ID
- `state_bucket_name`: The state bucket name

## Rollback Procedures

### If terraform apply fails partway through

**Scenario**: Apply fails after project creation but before bucket creation

```bash
# Check what was created
gcloud projects list --filter="projectId:{project_name}-bootstrap"

# Let terraform retry (safest approach)
terraform -chdir=platform/0-bootstrap apply

# Or manually clean up and retry
gcloud projects delete {project_name}-bootstrap --quiet
rm -f terraform.tfstate*
terraform -chdir=platform/0-bootstrap apply
```

### If you need to completely destroy bootstrap

**Warning**: This deletes the state bucket and all terraform state. Only do this if you're starting over.

```bash
# Disable prevent_destroy in platform/0-bootstrap/main.tf first
# Change: lifecycle { prevent_destroy = true }
# To: lifecycle { prevent_destroy = false }

terraform -chdir=platform/0-bootstrap destroy

# Manually delete project if destroy fails
gcloud projects delete {project_name}-bootstrap --quiet
```

### If state bucket already exists error

**Cause**: Bucket name is globally taken or recently deleted

```bash
# Try a different bucket name in terraform.tfvars
state_bucket_name = "yourorg-tfstate-abc123"  # Add random suffix

# Or restore the bucket if it was recently deleted (within 30 days)
gsutil ls -p {project_id} -L gs://{bucket_name}
```

## Recovery

If local state is lost before migration, re-import resources:

```bash
terraform import google_project.bootstrap {project_id}
terraform import google_storage_bucket.tf_state {bucket_name}
terraform import 'google_project_service.enabled["cloudresourcemanager.googleapis.com"]' {project_id}/cloudresourcemanager.googleapis.com
terraform import 'google_project_service.enabled["iam.googleapis.com"]' {project_id}/iam.googleapis.com
terraform import 'google_project_service.enabled["serviceusage.googleapis.com"]' {project_id}/serviceusage.googleapis.com
terraform import 'google_project_service.enabled["storage.googleapis.com"]' {project_id}/storage.googleapis.com
```
