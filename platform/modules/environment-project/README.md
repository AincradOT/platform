# environment-project module

Reusable module for creating GCP environment projects with consistent configuration.

## What this creates

- GCP project in specified folder
- Standard APIs (compute, IAM, logging, monitoring, Secret Manager)
- Monitoring attachment to central metrics scope
- Optional CI service account IAM binding
- Optional custom IAM bindings

## Usage

```hcl
module "dev_environment" {
  source = "../../modules/environment-project"

  billing_account_id = "ABCDEF-123456-ABCDEF"
  folder_id          = "folders/123456789012"
  shared_project_id  = "aincrad-shared"
  project_id         = "aincrad-dev"
  environment_name   = "development"

  project_display_name = "Development"
  ci_service_account   = "dev-ci@aincrad-shared.iam.gserviceaccount.com"

  iam_bindings = {
    platform_devs = {
      role   = "roles/compute.instanceAdmin.v1"
      member = "group:platform-devs@example.com"
    }
  }

  labels = {
    team = "platform"
  }
}
```

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `billing_account_id` | Billing account ID | `string` | Yes | - |
| `folder_id` | Parent folder ID | `string` | Yes | - |
| `shared_project_id` | Shared services project ID for metrics scope | `string` | Yes | - |
| `project_id` | Unique project ID | `string` | Yes | - |
| `environment_name` | Environment name for labeling (development, production, etc.) | `string` | Yes | - |
| `project_display_name` | Display name for project | `string` | No | Same as `project_id` |
| `ci_service_account` | CI service account email to grant editor role | `string` | No | `null` |
| `ci_storage_admin` | Grant CI service account `roles/storage.admin` on this project | `bool` | No | `false` |
| `iam_bindings` | Additional IAM bindings (map of {role, member}) | `map(object)` | No | `{}` |
| `labels` | Additional resource labels | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | The created project ID |
| `project_number` | The created project number |

## Notes

- This module enables APIs: compute, IAM, logging, monitoring, Secret Manager
- Additional APIs can be enabled in the consuming application's terraform
- IAM bindings include only CI service account access - add project-specific permissions in application repos
- Set `ci_storage_admin = true` when CI needs to create or manage buckets in this project.
