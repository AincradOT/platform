# 2-environments: production

Creates production environment project.

## What this creates

- Production project in `prod` folder
- Minimal APIs enabled (compute, IAM, logging, monitoring, Secret Manager)
- Project attached to central logging metrics scope
- Optional IAM bindings for platform viewers

## Configuration

Update `backends.tf` with your state bucket from `0-bootstrap` output.

Create `terraform.tfvars`:

```hcl
billing_account_id = "ABCDEF-123456-ABCDEF"
state_bucket_name  = "aincrad-tfstate"  # From 0-bootstrap output
prod_project_id    = "aincrad-prod"
```

Values like `folder_id`, `shared_project_id`, and `prod_ci_service_account` are **automatically pulled from 1-org remote state**. You only need to override them if you need non-standard values.

Optional overrides:

```hcl
# Only uncomment if you need to override remote state values
# folder_id               = "folders/123456789012"
# shared_project_id       = "aincrad-shared"
# prod_ci_service_account = "prod-ci@aincrad-shared.iam.gserviceaccount.com"
# gcp_platform_viewers_group = "platform-viewers@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `billing_account_id` | Billing account ID | Yes |
| `state_bucket_name` | GCS state bucket name (from `0-bootstrap` output) for remote state data source | Yes |
| `prod_project_id` | Unique project ID for production | Yes |
| `folder_id` | Parent folder ID - auto-pulled from `1-org` remote state, override if needed | No |
| `shared_project_id` | Shared services project ID - auto-pulled from `1-org` remote state, override if needed | No |
| `prod_ci_service_account` | Prod CI service account email - auto-pulled from `1-org` remote state, override if needed | No |
| `prod_project_name` | Display name for project | No (default: "Production") |
| `gcp_platform_viewers_group` | Group email for viewer access | No |
| `labels` | Resource labels | No |

## Outputs

- `prod_project_id` - Production project ID

## Rollback Procedures

### If terraform apply fails partway through

**Scenario**: Project created but API enablement fails

```bash
# Check what was created
gcloud projects describe {prod_project_id}
gcloud services list --project={prod_project_id} --enabled

# Retry terraform apply
terraform -chdir=platform/2-environments/production apply

# Or manually enable failed APIs then retry
gcloud services enable compute.googleapis.com --project={prod_project_id}
terraform -chdir=platform/2-environments/production apply
```

### If you need to destroy the prod environment

**Warning**: This deletes the production project and all resources within it. Only do this if you're certain.

```bash
# Verify no critical resources exist
gcloud compute instances list --project={prod_project_id}
gcloud sql instances list --project={prod_project_id}

# Destroy
terraform -chdir=platform/2-environments/production destroy

# If destroy fails due to resources still in project
# Manually delete resources via console first, then:
terraform -chdir=platform/2-environments/production destroy
```

### If remote state data source fails

**Cause**: 1-org remote state not found or bucket inaccessible

```bash
# Verify state bucket exists
gsutil ls gs://{state_bucket_name}/terraform/org/

# Override with explicit values in terraform.tfvars if needed
folder_id               = "folders/123456789012"
shared_project_id       = "yourorg-shared"
prod_ci_service_account = "prod-ci@yourorg-shared.iam.gserviceaccount.com"

terraform -chdir=platform/2-environments/production apply
```

### If project already exists error

**Cause**: Project ID is taken or recently deleted (30-day retention)

```bash
# Check if project exists
gcloud projects describe {prod_project_id}

# Undelete if recently deleted
gcloud projects undelete {prod_project_id}
terraform -chdir=platform/2-environments/production import module.prod_environment.google_project.env {prod_project_id}

# Or use different project ID in terraform.tfvars
prod_project_id = "yourorg-prod-v2"
terraform -chdir=platform/2-environments/production apply
```

## Notes

- IAM is minimal. Keep production tight - add permissions explicitly as needed
