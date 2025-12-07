# ====================================================================
# GitHub Organization Settings Configuration
# This module manages organization-wide settings including security
# policies, repository permissions, member capabilities, and advanced
# security features. It provides centralized control over organization
# behavior and default repository settings for new repositories.
# ====================================================================

resource "github_organization_settings" "org" {
  billing_email    = var.org_settings.billing_email
  company          = var.org_settings.company
  blog             = var.org_settings.blog
  email            = var.org_settings.email
  twitter_username = var.org_settings.twitter_username
  location         = var.org_settings.location
  description      = var.org_settings.description

  has_organization_projects     = var.org_settings.has_organization_projects
  has_repository_projects       = var.org_settings.has_repository_projects
  default_repository_permission = var.org_settings.default_repository_permission

  members_can_create_repositories          = var.org_settings.members_can_create_repositories
  members_can_create_public_repositories   = var.org_settings.members_can_create_public_repositories
  members_can_create_private_repositories  = var.org_settings.members_can_create_private_repositories
  members_can_create_internal_repositories = var.org_settings.members_can_create_internal_repositories

  members_can_create_pages         = var.org_settings.members_can_create_pages
  members_can_create_public_pages  = var.org_settings.members_can_create_public_pages
  members_can_create_private_pages = var.org_settings.members_can_create_private_pages

  members_can_fork_private_repositories = var.org_settings.members_can_fork_private_repositories
  web_commit_signoff_required           = var.org_settings.web_commit_signoff_required

  advanced_security_enabled_for_new_repositories = var.org_settings.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories = var.org_settings.dependabot_alerts_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories  = var.org_settings.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories   = var.org_settings.secret_scanning_enabled_for_new_repositories

  lifecycle {
    # Ignore changes to settings that might be managed outside Terraform
    # or require special permissions (like billing contact information)
    ignore_changes = [
      billing_email,
      company,
      blog,
      email,
      twitter_username,
      location,
      description
    ]
  }
}
