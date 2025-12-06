# 1-org

Creates organizational structure and shared services.

## What this creates

- Three top-level folders: `shared`, `dev`, `prod`
- Central logging/monitoring project in `shared` folder
- Org policy to prevent default VPC creation
- Optional IAM bindings for logging viewers

## Configuration

Update `backends.tf` with your state bucket from `0-bootstrap` output.

Create `terraform.tfvars`:

```hcl
org_id                     = "123456789012"
billing_account_id         = "ABCDEF-123456-ABCDEF"
logging_project_id         = "yourorg-shared-logging"
logging_project_name       = "Shared Logging"
gcp_logging_viewers_group  = "logging-viewers@example.com"
gcp_org_admins_group       = "platform-admins@example.com"
gcp_billing_admins_group   = "billing-admins@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `org_id` | GCP organization ID | Yes |
| `billing_account_id` | Billing account ID | Yes |
| `logging_project_id` | Unique project ID for central logging | Yes |
| `logging_project_name` | Display name for logging project | No (default: "Shared Logging") |
| `gcp_logging_viewers_group` | Group email for logging read access | No |
| `gcp_org_admins_group` | Group email for org-level project creation | No |
| `gcp_billing_admins_group` | Group email for billing admin | No |
| `labels` | Resource labels | No |

## Outputs

- `shared_folder_id` - Shared folder ID
- `dev_folder_id` - Development folder ID
- `prod_folder_id` - Production folder ID
- `logging_project_id` - Central logging project ID

## Notes

- IAM is minimal at org level. Project-level IAM is in `2-environments/`
- Groups are not created by terraform to avoid domain coupling
- Provide group emails via variables
