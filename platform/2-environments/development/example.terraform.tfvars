# ============================================================================
# Terraform Variables for Development Environment
# ============================================================================
# Copy this file to terraform.tfvars and update with your actual values.
#
# This root creates the development project with basic APIs and IAM.
# Values like folder_id and shared_project_id are automatically pulled from
# 1-org remote state, so you only need to specify project ID and state bucket.
# ============================================================================

# Billing account ID (same as used in 0-bootstrap)
billing_account_id = "ABCDEF-123456-ABCDEF"

# State bucket name from 0-bootstrap output (used to read 1-org remote state)
state_bucket_name = "aincrad-tfstate"

# Unique project ID for development environment
dev_project_id = "aincrad-dev"

# ============================================================================
# Optional Overrides
# ============================================================================
# The following values are automatically pulled from 1-org remote state.
# Only uncomment if you need to override the remote state values.

# folder_id = "folders/123456789012"
# shared_project_id = "aincrad-shared"
# dev_ci_service_account = "dev-ci@aincrad-shared.iam.gserviceaccount.com"

# Optional: Platform developers group email
# Grants compute.instanceAdmin.v1 role for managing VMs
# gcp_platform_devs_group = "platform-devs@example.com"
