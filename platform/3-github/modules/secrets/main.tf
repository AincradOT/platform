# ====================================================================
# GitHub Organization Secrets Management Configuration
# This module manages organization-level GitHub Actions secrets
# including GitHub App ID, Installation ID, and Private Key (PEM)
# These secrets are available to all repositories in the organization.
# ====================================================================

resource "github_actions_organization_secret" "gh_app_id" {
  secret_name     = "AINCRAD_APP_ID"
  plaintext_value = var.github_app_id
  visibility      = "all"

  lifecycle {
    ignore_changes = [
      plaintext_value,
      visibility
    ]
  }
}

resource "github_actions_organization_secret" "gh_app_installation_id" {
  secret_name     = "AINCRAD_APP_INSTALLATION_ID"
  plaintext_value = var.github_app_installation_id
  visibility      = "all"

  lifecycle {
    ignore_changes = [
      plaintext_value,
      visibility
    ]
  }
}

resource "github_actions_organization_secret" "gh_app_pem" {
  secret_name     = "AINCRAD_APP_PEM"
  plaintext_value = var.github_app_pem_file
  visibility      = "all"

  lifecycle {
    ignore_changes = [
      plaintext_value,
      visibility
    ]
  }
}
