# 1-org

Creates organizational structure and shared services.

## What this creates

- Three top-level folders: `shared`, `dev`, `prod`
- Shared services project in `shared` folder (logging, monitoring, service accounts, secrets)
- CI service accounts for GitHub Actions (platform, dev, prod)
- Cloud Identity groups (logging-viewers, platform-admins, billing-admins)
- IAM bindings for groups (logging viewer access, platform admin access, billing admin access)
- Org policy to prevent default VPC creation

## Additional Resources

- [GCP Organization Structure](https://cloud.google.com/resource-manager/docs/creating-managing-organization) - Organization and folder hierarchy
- [Organization Policies](https://cloud.google.com/resource-manager/docs/organization-policy/overview) - Centralized policy management
- [Service Accounts Best Practices](https://cloud.google.com/iam/docs/best-practices-service-accounts) - IAM for automation
- [GCP Folders](https://cloud.google.com/resource-manager/docs/creating-managing-folders) - Organizing resources

!!! note
    For step-by-step bootstrap instructions, see the [Platform README](../README.md).
    This document provides reference information for the 1-org terraform root.

## Configuration

Create `terraform.tfvars`:

```hcl
org_id              = "123456789012"
billing_account_id  = "ABCDEF-123456-ABCDEF"
shared_project_id   = "aincrad-shared"
state_bucket_name   = "aincrad-tfstate"  # From 0-bootstrap output

# API credentials (only for initial bootstrap - see platform/README.md step 9)
github_app_id              = "123456"
github_app_installation_id = "12345678"
github_app_private_key     = <<-EOT
-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----
EOT
cloudflare_api_token       = "abc123def456ghi789jkl012mno345pqr678stu901vwx234yz"
cloudflare_zone_id         = "1234567890abcdef1234567890abcdef"

# SSH connection details for OVH VPS machines (only for initial bootstrap)
dev_vps_ssh_host     = "51.38.185.123"
dev_vps_ssh_user     = "ubuntu"
dev_vps_ssh_password = "your-dev-password"
dev_vps_ssh_private_key = <<-EOT
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
EOT

prod_vps_ssh_host     = "51.38.186.234"
prod_vps_ssh_user     = "ubuntu"
prod_vps_ssh_password = "your-prod-password"
prod_vps_ssh_private_key = <<-EOT
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
EOT
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `org_id` | GCP organization ID | Yes |
| `billing_account_id` | Billing account ID | Yes |
| `shared_project_id` | Unique project ID for shared services | Yes |
| `shared_project_name` | Display name for shared services project | No (default: "Shared Services") |
| `state_bucket_name` | State bucket name from 0-bootstrap | Yes (for CI service account state access) |
| `labels` | Resource labels | No |
| `github_app_id` | GitHub App ID (for initial Secret Manager sync only) | No (default: null) |
| `github_app_installation_id` | GitHub App Installation ID (for initial Secret Manager sync only) | No (default: null) |
| `github_app_private_key` | GitHub App private key PEM contents (for initial Secret Manager sync only) | No (default: null) |
| `cloudflare_api_token` | Cloudflare API token (for initial Secret Manager sync only) | No (default: null) |
| `cloudflare_zone_id` | Cloudflare Zone ID for your domain (for initial Secret Manager sync only) | No (default: null) |
| `dev_vps_ssh_host` | Development VPS SSH hostname or IP (for initial Secret Manager sync only) | No (default: null) |
| `dev_vps_ssh_user` | Development VPS SSH username (for initial Secret Manager sync only) | No (default: null) |
| `dev_vps_ssh_password` | Development VPS SSH password (for initial Secret Manager sync only) | No (default: null) |
| `dev_vps_ssh_private_key` | Development VPS SSH private key PEM (for initial Secret Manager sync only) | No (default: null) |
| `prod_vps_ssh_host` | Production VPS SSH hostname or IP (for initial Secret Manager sync only) | No (default: null) |
| `prod_vps_ssh_user` | Production VPS SSH username (for initial Secret Manager sync only) | No (default: null) |
| `prod_vps_ssh_password` | Production VPS SSH password (for initial Secret Manager sync only) | No (default: null) |
| `prod_vps_ssh_private_key` | Production VPS SSH private key PEM (for initial Secret Manager sync only) | No (default: null) |

## Outputs

- `org_id` - Organization ID
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

- Org-level IAM grants only folder/project creation permissions. Project-level IAM is in `2-environments/`
- Cloud Identity groups are created automatically by terraform during apply
- Group membership is managed manually via Google Admin console after terraform creates the groups
- CI service accounts require key generation via `gcloud iam service-accounts keys create` for GitHub Actions
- Service account keys should be stored as GitHub organization secrets

## Secret Manager IAM

The following IAM bindings are automatically created for Secret Manager secrets:

**Cloudflare API Token:**
- `dev-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`
- `prod-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`

Used by application infrastructure modules to authenticate with Cloudflare API.

**Cloudflare Zone ID:**
- `dev-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`
- `prod-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`

Used by application infrastructure modules to manage DNS records in the correct Cloudflare zone.

**GitHub App Credentials:**
- `platform-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`

Used by platform infrastructure (3-github module) to manage GitHub organization settings via GitHub Terraform provider.

**VPS SSH Credentials (optional):**

Development VPS:
- `dev-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`

Production VPS:
- `prod-ci@<shared-project>.iam.gserviceaccount.com` - `roles/secretmanager.secretAccessor`

Used by application deployment workflows (Ansible, configuration management) to provision and configure VPS infrastructure. Only required if using VPS hosting pattern for application infrastructure.
