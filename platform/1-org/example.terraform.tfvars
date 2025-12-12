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

cloudflare_api_token = "cfx_api_v1_1234567890abcdef1234567890abcdef"
cloudflare_zone_id   = "023e10593bd81a4dd053a95b8"

# SSH connection details for OVH VPS machines
# Only needed for initial bootstrap to sync to Secret Manager
# After initial sync, remove these lines from terraform.tfvars

# Development VPS
dev_vps_ssh_host     = "51.38.185.123"
dev_vps_ssh_user     = "ubuntu"
dev_vps_ssh_password = "your-dev-vps-password"
dev_vps_ssh_private_key = <<-EOT
-----BEGIN OPENSSH PRIVATE KEY-----
abcdef
...
-----END OPENSSH PRIVATE KEY-----
EOT

# Production VPS
prod_vps_ssh_host     = "51.38.186.234"
prod_vps_ssh_user     = "ubuntu"
prod_vps_ssh_password = "your-prod-vps-password"
prod_vps_ssh_private_key = <<-EOT
-----BEGIN OPENSSH PRIVATE KEY-----
abcdef
...
-----END OPENSSH PRIVATE KEY-----
EOT

# GitHub App credentials for dual storage (GitHub org secrets + GCP Secret Manager)
# Only needed for initial bootstrap to sync to Secret Manager
# See platform/README.md step 9 for details
# After initial sync, remove these lines from terraform.tfvars

github_app_id              = "123456"
github_app_installation_id = "12345678"
github_app_private_key     = <<-EOT
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...
-----END RSA PRIVATE KEY-----
EOT
