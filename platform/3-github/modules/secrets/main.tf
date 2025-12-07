# ====================================================================
# GitHub Organization Secrets Management Configuration
# This module manages organization-level GitHub Actions secrets
# including Renovate token for automated dependency updates and
# GitHub Container Registry (GHCR) token for private registry access.
# These secrets are available to all repositories in the organization.
# ====================================================================

# Generate GitHub App token for organization-level operations
data "github_app_token" "org" {
  app_id          = var.github_app_id
  installation_id = var.github_app_installation_id
  pem_file        = var.github_app_pem_file
}

# Organization-level Renovate token for automated dependency updates
resource "github_actions_organization_secret" "renovate_token" {
  secret_name     = "RENOVATE_TOKEN"
  plaintext_value = data.github_app_token.org.token
  visibility      = "all"
}

# Organization-level GHCR token for private registry access
resource "github_actions_organization_secret" "ghcr_token_private" {
  secret_name     = "GHCR_TOKEN_PRIVATE"
  plaintext_value = data.github_app_token.org.token
  visibility      = "all"
}

# Organization-level GitHub Pages token for  repository page deployments
resource "github_actions_organization_secret" "pages_token" {
  secret_name     = "PAGES_TOKEN"
  plaintext_value = data.github_app_token.org.token
  visibility      = "all"
}
