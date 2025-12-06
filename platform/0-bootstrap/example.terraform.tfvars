# ============================================================================
# Terraform Variables for 0-bootstrap
# ============================================================================
# Copy this file to terraform.tfvars and update with your values.
#
# The bootstrap project ID will be auto-generated as: {project_name}-bootstrap
# ============================================================================

# GCP organization ID (find at: https://console.cloud.google.com/iam-admin/settings)
org_id = "123456789012"

# Billing account ID (find at: https://console.cloud.google.com/billing)
billing_account_id = "XXXXXX-YYYYYY-ZZZZZZ"

# Project name (e.g., "sao")
# This generates project_id: "sao-bootstrap"
project_name = "sao"

# Globally-unique GCS bucket name for Terraform state
state_bucket_name = "sao-tfstate"
