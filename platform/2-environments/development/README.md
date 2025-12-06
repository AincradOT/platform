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
logging_project_id           = "yourorg-shared-logging"
dev_project_id               = "yourorg-dev"
dev_project_name             = "Development"
gcp_platform_viewers_group   = "platform-viewers@example.com"
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `billing_account_id` | Billing account ID | Yes |
| `folder_id` | Parent folder ID (from `1-org` output) | Yes |
| `logging_project_id` | Central logging project ID (from `1-org` output) | Yes |
| `dev_project_id` | Unique project ID for development | Yes |
| `dev_project_name` | Display name for project | No (default: "Development") |
| `gcp_platform_viewers_group` | Group email for viewer access | No |
| `labels` | Resource labels | No |

## Outputs

- `dev_project_id` - Development project ID

## Notes

- IAM is minimal. Add project-specific roles as needed for your application
