# ============================================================================
# Terraform Variables for Production Environment
# ============================================================================
# Copy this file to terraform.tfvars and update with your actual values.
#
# This root creates the production project with basic APIs and IAM.
# Keep production IAM tight - add permissions explicitly as needed.
# ============================================================================

# Billing account ID (same as used in 0-bootstrap)
billing_account_id = "ABCDEF-123456-ABCDEF"

# Production folder ID from 1-org output
# Run: terraform -chdir=platform/1-org output prod_folder_id
folder_id = "folders/123456789012"

# Central logging project ID from 1-org output
# Run: terraform -chdir=platform/1-org output logging_project_id
logging_project_id = "sao-shared-logging"

# Unique project ID for production environment
prod_project_id = "sao-prod"

# Optional: Prod CI service account email from 1-org output
# Run: terraform -chdir=platform/1-org output prod_ci_service_account
# Uncomment to grant editor role on prod project:
# prod_ci_service_account = "prod-ci@sao-shared-logging.iam.gserviceaccount.com"

# Optional: Platform viewers group email
# Grants viewer role for read-only access to production
# gcp_platform_viewers_group = "platform-viewers@example.com"
