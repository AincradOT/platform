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
shared_project_id          = "sao-shared"
shared_project_name        = "Shared Services"
state_bucket_name          = "sao-tfstate"  # From 0-bootstrap output
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
| `state_bucket_name` | GCS state bucket name (from `0-bootstrap` output) for CI service account IAM | No |
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

## Notes

- IAM is minimal at org level. Project-level IAM is in `2-environments/`
- Groups are not created by terraform to avoid domain coupling
- Provide group emails via variables
- CI service accounts require key generation via `gcloud iam service-accounts keys create` for GitHub Actions
- Service account keys should be stored as GitHub organization secrets and rotated quarterly
