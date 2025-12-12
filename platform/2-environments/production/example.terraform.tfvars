# ============================================================================
# Terraform Variables for Production Environment
# ============================================================================
# Copy this file to terraform.tfvars and update with your actual values.
#
# This root creates the production project with basic APIs and IAM.
# Values like folder_id and shared_project_id are automatically pulled from
# 1-org remote state, so you only need to specify project ID and state bucket.
# Keep production IAM tight - add permissions explicitly as needed.
# ============================================================================

# Billing account ID (same as used in 0-bootstrap)
billing_account_id = "ABCDEF-123456-ABCDEF"

# State bucket name from 0-bootstrap output (used to read 1-org remote state)
state_bucket_name = "aincrad-tfstate"

# Unique project ID for production environment
prod_project_id = "aincrad-prod"

# ============================================================================
# Optional Overrides
# ============================================================================
# The following values are automatically pulled from 1-org remote state.
# Only uncomment if you need to override the remote state values.

# folder_id = "folders/123456789012"
# shared_project_id = "aincrad-shared"
# prod_ci_service_account = "prod-ci@aincrad-shared.iam.gserviceaccount.com"

# Optional: Platform viewers group email
# Grants viewer role for read-only access to production
# gcp_platform_viewers_group = "platform-viewers@example.com"
