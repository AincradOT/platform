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
billing_account_id           = "ABCDEF-123456-ABCDEF"
folder_id                    = "folders/123456789012"  # From 1-org output
shared_project_id            = "sao-shared"
dev_project_id               = "sao-dev"
dev_project_name             = "Development"
dev_ci_service_account       = "dev-ci@sao-shared.iam.gserviceaccount.com"  # From 1-org output
gcp_platform_devs_group      = "platform-devs@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `billing_account_id` | Billing account ID | Yes |
| `folder_id` | Parent folder ID (from `1-org` output) | Yes |
| `shared_project_id` | Shared services project ID (from `1-org` output) | Yes |
| `dev_project_id` | Unique project ID for development | Yes |
| `dev_project_name` | Display name for project | No (default: "Development") |
| `dev_ci_service_account` | Dev CI service account email (from `1-org` output) for granting editor role | No |
| `gcp_platform_devs_group` | Group email for platform developers (grants `roles/compute.instanceAdmin.v1`) | No |
| `labels` | Resource labels | No |

## Outputs

- `dev_project_id` - Development project ID

## Notes

- IAM is minimal. Add project-specific roles as needed for your application
