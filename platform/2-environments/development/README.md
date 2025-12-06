# 2-environments: development

Creates development environment project.

## What this creates

- Development project in `dev` folder
- Minimal APIs enabled (compute, IAM, logging, monitoring, Secret Manager)
- Project attached to central logging metrics scope
- Optional IAM bindings for platform viewers

## Configuration

Update `backends.tf` with your state bucket from `0-bootstrap` output.

Create `terraform.tfvars`:

```hcl
billing_account_id = "ABCDEF-123456-ABCDEF"
state_bucket_name  = "sao-tfstate"  # From 0-bootstrap output
dev_project_id     = "sao-dev"
```

Values like `folder_id`, `shared_project_id`, and `dev_ci_service_account` are **automatically pulled from 1-org remote state**. You only need to override them if you need non-standard values.

Optional overrides:

```hcl
# Only uncomment if you need to override remote state values
# folder_id              = "folders/123456789012"
# shared_project_id      = "sao-shared"
# dev_ci_service_account = "dev-ci@sao-shared.iam.gserviceaccount.com"
# gcp_platform_devs_group = "platform-devs@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `billing_account_id` | Billing account ID | Yes |
| `state_bucket_name` | GCS state bucket name (from `0-bootstrap` output) for remote state data source | Yes |
| `dev_project_id` | Unique project ID for development | Yes |
| `folder_id` | Parent folder ID - auto-pulled from `1-org` remote state, override if needed | No |
| `shared_project_id` | Shared services project ID - auto-pulled from `1-org` remote state, override if needed | No |
| `dev_ci_service_account` | Dev CI service account email - auto-pulled from `1-org` remote state, override if needed | No |
| `dev_project_name` | Display name for project | No (default: "Development") |
| `gcp_platform_devs_group` | Group email for platform developers (grants `roles/compute.instanceAdmin.v1`) | No |
| `labels` | Resource labels | No |

## Outputs

- `dev_project_id` - Development project ID

## Notes

- IAM is minimal. Add project-specific roles as needed for your application
