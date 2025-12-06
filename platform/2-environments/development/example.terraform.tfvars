# ============================================================================
# Terraform Variables for Development Environment
# ============================================================================
# Copy this file to terraform.tfvars and update with your actual values.
#
# This root creates the development project with basic APIs and IAM.
# ============================================================================

# Billing account ID (same as used in 0-bootstrap)
billing_account_id = "ABCDEF-123456-ABCDEF"

# Development folder ID from 1-org output
# Run: terraform -chdir=platform/1-org output dev_folder_id
folder_id = "folders/123456789012"

# Shared services project ID from 1-org output
# Run: terraform -chdir=platform/1-org output shared_project_id
shared_project_id = "sao-shared"

# Unique project ID for development environment
dev_project_id = "sao-dev"

# Optional: Dev CI service account email from 1-org output
# Run: terraform -chdir=platform/1-org output dev_ci_service_account
# Uncomment to grant editor role on dev project:
# dev_ci_service_account = "dev-ci@sao-shared.iam.gserviceaccount.com"

# Optional: Platform developers group email
# Grants compute.instanceAdmin.v1 role for managing VMs
# gcp_platform_devs_group = "platform-devs@example.com"
