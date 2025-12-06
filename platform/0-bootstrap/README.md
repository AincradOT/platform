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

## Setup

1. Copy example tfvars file:
   ```bash
   cp platform/0-bootstrap/example.terraform.tfvars platform/0-bootstrap/terraform.tfvars
   ```

2. Edit `platform/0-bootstrap/terraform.tfvars` with your values.

3. Initialize and apply:

   **Option A - From repository root:**
   ```bash
   terraform -chdir=platform/0-bootstrap init
   terraform -chdir=platform/0-bootstrap apply
   ```

   **Option B - From this directory:**
   ```bash
   cd platform/0-bootstrap
   terraform init
   terraform apply
   ```

4. Note the `state_bucket_name` output:

   **From repository root:**
   ```bash
   terraform -chdir=platform/0-bootstrap output state_bucket_name
   ```

   **From this directory:**
   ```bash
   terraform output state_bucket_name
   ```

## Migrate to Remote State

1. Edit `platform/0-bootstrap/backend.gcs.example.tf`:
   - Update `bucket` with the state bucket name from output
   - Uncomment the `terraform` block

2. Rename and migrate (from repository root):
   ```bash
   mv platform/0-bootstrap/backend.gcs.example.tf platform/0-bootstrap/backend.gcs.tf
   terraform -chdir=platform/0-bootstrap init -migrate-state
   ```
   Type `yes` when prompted.

## Configure Other Roots

Update the `bucket` value in:
- `platform/1-org/backends.tf`
- `platform/2-environments/development/backends.tf`
- `platform/2-environments/production/backends.tf`

Then initialize each root (from repository root):
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
| `location` | GCS bucket location | No (default: `europe-west3`) |
| `labels` | Resource labels | No |

## Outputs

- `bootstrap_project_id`: The created project ID
- `state_bucket_name`: The state bucket name

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
