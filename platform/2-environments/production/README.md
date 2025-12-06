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
billing_account_id            = "ABCDEF-123456-ABCDEF"
folder_id                     = "folders/123456789012"  # From 1-org output
shared_project_id             = "sao-shared"
prod_project_id               = "sao-prod"
prod_project_name             = "Production"
prod_ci_service_account       = "prod-ci@sao-shared.iam.gserviceaccount.com"  # From 1-org output
gcp_platform_viewers_group    = "platform-viewers@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `billing_account_id` | Billing account ID | Yes |
| `folder_id` | Parent folder ID (from `1-org` output) | Yes |
| `shared_project_id` | Shared services project ID (from `1-org` output) | Yes |
| `prod_project_id` | Unique project ID for production | Yes |
| `prod_project_name` | Display name for project | No (default: "Production") |
| `prod_ci_service_account` | Prod CI service account email (from `1-org` output) for granting editor role | No |
| `gcp_platform_viewers_group` | Group email for viewer access | No |
| `labels` | Resource labels | No |

## Outputs

- `prod_project_id` - Production project ID

## Notes

- IAM is minimal. Keep production tight - add permissions explicitly as needed
