# 1-org

Creates organizational structure and shared services.

## What this creates

- Three top-level folders: `shared`, `dev`, `prod`
- Shared services project in `shared` folder (logging, monitoring, service accounts, secrets)
- CI service accounts for GitHub Actions (platform, dev, prod)
- Org policy to prevent default VPC creation
- Optional IAM bindings for logging viewers

## Configuration

Update `backends.tf` with your state bucket from `0-bootstrap` output.

Create `terraform.tfvars`:

```hcl
org_id                     = "123456789012"
billing_account_id         = "ABCDEF-123456-ABCDEF"
shared_project_id          = "aincrad-shared"
shared_project_name        = "Shared Services"
state_bucket_name          = "aincrad-tfstate"  # From 0-bootstrap output
gcp_logging_viewers_group  = "logging-viewers@example.com"
gcp_org_admins_group       = "platform-admins@example.com"
gcp_billing_admins_group   = "billing-admins@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `org_id` | GCP organization ID | Yes |
| `billing_account_id` | Billing account ID | Yes |
| `shared_project_id` | Unique project ID for shared services | Yes |
| `shared_project_name` | Display name for shared services project | No (default: "Shared Services") |
| `state_bucket_name` | GCS state bucket name (from `0-bootstrap` output) for CI service account IAM | No (default: `null`) |
| `gcp_logging_viewers_group` | Group email for logging read access | No |
| `gcp_org_admins_group` | Group email for org-level project creation | No |
| `gcp_billing_admins_group` | Group email for billing admin | No |
| `labels` | Resource labels | No |

## Outputs

- `shared_folder_id` - Shared folder ID
- `dev_folder_id` - Development folder ID
- `prod_folder_id` - Production folder ID
- `shared_project_id` - Shared services project ID
- `platform_ci_service_account` - Platform CI service account email
- `dev_ci_service_account` - Development CI service account email
- `prod_ci_service_account` - Production CI service account email

## Rollback Procedures

### If terraform apply fails partway through

**Scenario**: Folders created but shared project fails

```bash
# Check what was created
gcloud resource-manager folders list --organization={org_id}
gcloud projects list --filter="parent.id={folder_id}"

# Fix the issue and retry
terraform -chdir=platform/1-org apply

# Or destroy and start over
terraform -chdir=platform/1-org destroy
```

### If you need to rollback org structure changes

**Warning**: This will delete folders, the shared project, and all service accounts. Ensure no environment projects exist first.

```bash
# Destroy environments first (see 2-environments rollback)
terraform -chdir=platform/2-environments/production destroy
terraform -chdir=platform/2-environments/development destroy

# Then destroy org structure
terraform -chdir=platform/1-org destroy
```

### If service account creation fails

**Cause**: Project doesn't exist or IAM API not enabled

```bash
# Verify shared project exists
gcloud projects describe {shared_project_id}

# Enable IAM API manually if needed
gcloud services enable iam.googleapis.com --project={shared_project_id}

# Retry
terraform -chdir=platform/1-org apply
```

### If org policy conflicts

**Cause**: Existing org policies conflict with skipDefaultNetworkCreation

```bash
# List existing org policies
gcloud org-policies list --organization={org_id}

# Reset conflicting policy manually via console if needed
# Then retry terraform apply
```

## Notes

- IAM is minimal at org level. Project-level IAM is in `2-environments/`
- Groups are not created by terraform to avoid domain coupling
- Provide group emails via variables
- CI service accounts require key generation via `gcloud iam service-accounts keys create` for GitHub Actions
- Service account keys should be stored as GitHub organization secrets
