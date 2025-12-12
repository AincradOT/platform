# ============================================================================
# Terraform Variables for 3-github
# ============================================================================
# Copy this file to terraform.tfvars and update with your actual values.
#
# This root manages GitHub organization infrastructure including teams,
# organization settings, and GitHub organization secrets.
#
# GitHub App credentials are automatically read from Secret Manager.
# No manual credential configuration required.
# ============================================================================

# Shared services project ID (from 1-org output)
shared_project_id = "aincrad-shared"

# GitHub organization name
github_organization = "aincradot"

# Team configuration
teams = {
  developers = {
    description = "Core developers"
    members     = ["your-github-username"]
  }
  admins = {
    description = "Organization administrators"
    members     = ["your-github-username"]
  }
}

default_branch = "master"

# ============================================================================
# Optional Variables
# ============================================================================

# Organization settings (optional)
# Leave commented out to manage all organization settings manually via GitHub UI
# org_settings = {
#   company     = "Your Company"
#   description = "Open Tibia game server infrastructure"
# }

# Default branch name for repositories
# Enable GitHub Advanced Security features
# enable_advanced_security = false
