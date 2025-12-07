# 2-environments: development

Creates development environment project.

## What this creates

- Development project in `dev` folder
- Minimal APIs enabled (compute, IAM, logging, monitoring, Secret Manager)
- Project attached to central logging metrics scope
- Optional IAM bindings for platform viewers

## Additional Resources

- [Remote State Data Sources](https://developer.hashicorp.com/terraform/language/state/remote-state-data) - Consuming outputs from other roots
- [GCP API Enablement](https://cloud.google.com/service-usage/docs/enable-disable) - Managing project APIs
- [Secret Manager Overview](https://cloud.google.com/secret-manager/docs) - Application secrets management
- [Cloud Monitoring Metrics Scopes](https://cloud.google.com/monitoring/settings) - Cross-project monitoring

!!! note
    For step-by-step bootstrap instructions, see the [Platform README](../../README.md).
    This document provides reference information for the development terraform root.

## Configuration

Create `terraform.tfvars`:

```hcl
billing_account_id = "ABCDEF-123456-ABCDEF"
state_bucket_name  = "aincrad-tfstate"  # From 0-bootstrap output
dev_project_id     = "aincrad-dev"
```

Values like `folder_id`, `shared_project_id`, and `dev_ci_service_account` are **automatically pulled from 1-org remote state**. You only need to override them if you need non-standard values.

Optional overrides:

```hcl
# Only uncomment if you need to override remote state values
# folder_id              = "folders/123456789012"
# shared_project_id      = "aincrad-shared"
# dev_ci_service_account = "dev-ci@aincrad-shared.iam.gserviceaccount.com"
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

## Rollback Procedures

### If terraform apply fails partway through

**Scenario**: Project created but API enablement fails

```bash
# Check what was created
gcloud projects describe {dev_project_id}
gcloud services list --project={dev_project_id} --enabled

# Retry terraform apply
terraform -chdir=platform/2-environments/development apply

# Or manually enable failed APIs then retry
gcloud services enable compute.googleapis.com --project={dev_project_id}
terraform -chdir=platform/2-environments/development apply
```

### If you need to destroy the dev environment

**Warning**: This deletes the dev project and all resources within it.

```bash
terraform -chdir=platform/2-environments/development destroy

# If destroy fails due to resources still in project
# Manually delete resources via console first, then:
terraform -chdir=platform/2-environments/development destroy
```

### If remote state data source fails

**Cause**: 1-org remote state not found or bucket inaccessible

```bash
# Verify state bucket exists
gsutil ls gs://{state_bucket_name}/terraform/org/

# Override with explicit values in terraform.tfvars if needed
folder_id              = "folders/123456789012"
shared_project_id      = "yourorg-shared"
dev_ci_service_account = "dev-ci@yourorg-shared.iam.gserviceaccount.com"

terraform -chdir=platform/2-environments/development apply
```

### If project already exists error

**Cause**: Project ID is taken or recently deleted (30-day retention)

```bash
# Check if project exists
gcloud projects describe {dev_project_id}

# Undelete if recently deleted
gcloud projects undelete {dev_project_id}
terraform -chdir=platform/2-environments/development import module.dev_environment.google_project.env {dev_project_id}

# Or use different project ID in terraform.tfvars
dev_project_id = "yourorg-dev-v2"
terraform -chdir=platform/2-environments/development apply
```

## Notes

- IAM is minimal. Add project-specific roles as needed for your application
