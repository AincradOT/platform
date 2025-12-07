# ============================================================================
# Terraform Variables for 1-org
# ============================================================================
# Copy this file to terraform.tfvars and update with your actual values.
#
# This root creates organizational folders, shared logging project, and
# CI service accounts for GitHub Actions.
# ============================================================================

# GCP organization ID (same as used in 0-bootstrap)
org_id = "123456789012"

# Billing account ID (same as used in 0-bootstrap)
billing_account_id = "ABCDEF-123456-ABCDEF"

# Unique project ID for shared services
# This will be created in the 'shared' folder
shared_project_id = "aincrad-shared"

# State bucket name from 0-bootstrap output
# Used to grant CI service accounts access to terraform state
state_bucket_name = "aincrad-tfstate"

# GitHub App credentials for platform automation
# See docs/requirements.md for instructions on creating the GitHub App
github_app_id              = "123456"
github_app_installation_id = "12345678"
github_app_private_key     = file("~/.config/github-apps/platform-automation.2024-12-07.private-key.pem")

# Optional: Group emails for IAM bindings
# Uncomment and set these if you have Google Workspace / Cloud Identity groups

# gcp_logging_viewers_group  = "logging-viewers@example.com"
# gcp_org_admins_group       = "platform-admins@example.com"
# gcp_billing_admins_group   = "billing-admins@example.com"
