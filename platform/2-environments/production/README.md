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
state_bucket_name  = "sao-tfstate"  # From 0-bootstrap output
prod_project_id    = "sao-prod"
```

Values like `folder_id`, `shared_project_id`, and `prod_ci_service_account` are **automatically pulled from 1-org remote state**. You only need to override them if you need non-standard values.

Optional overrides:

```hcl
# Only uncomment if you need to override remote state values
# folder_id               = "folders/123456789012"
# shared_project_id       = "sao-shared"
# prod_ci_service_account = "prod-ci@sao-shared.iam.gserviceaccount.com"
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

## Notes

- IAM is minimal. Keep production tight - add permissions explicitly as needed
