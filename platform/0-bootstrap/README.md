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

## Setup

1. Copy example tfvars file:
   ```bash
   cp platform/0-bootstrap/example.terraform.tfvars platform/0-bootstrap/terraform.tfvars
   ```

2. Edit `platform/0-bootstrap/terraform.tfvars` with your values.

3. Initialize and apply:

   ```bash
   terraform -chdir=platform/0-bootstrap init
   terraform -chdir=platform/0-bootstrap apply
   ```

4. Note the `state_bucket_name` output:

   ```bash
   terraform -chdir=platform/0-bootstrap output state_bucket_name
   ```

## Migrate to Remote State

1. Edit `platform/0-bootstrap/backends.tf`:
   - Uncomment the `terraform` block at the bottom of the file
   - Update `bucket` with the state bucket name from output

2. Migrate state (from repository root):
   ```bash
   terraform -chdir=platform/0-bootstrap init -migrate-state
   ```
   Type `yes` when prompted.

!!! note
    For fresh bootstrap, migration failure is low-risk. If migration fails:
    
    1. Check bucket name is correct in backends.tf
    2. Verify bucket exists: `gsutil ls gs://YOUR-BUCKET-NAME`
    3. Fix the issue and re-run: `terraform init -migrate-state`
    4. If still failing, keep local state and migrate later after verifying bucket access
    
    The resources are newly created and easy to recreate if needed.

## Configure Other Roots

Update the `bucket` value in:
- `platform/1-org/backends.tf`
- `platform/2-environments/development/backends.tf`
- `platform/2-environments/production/backends.tf`

Then initialize each root:
```bash
terraform -chdir=platform/1-org init
terraform -chdir=platform/2-environments/development init
terraform -chdir=platform/2-environments/production init
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `org_id` | GCP organization ID | Yes |
| `billing_account_id` | Billing account ID | Yes |
| `project_name` | Project name (e.g. `sao` generates project ID `sao-bootstrap`) | Yes |
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
