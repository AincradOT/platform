output "organization_settings" {
  description = "GitHub organization settings configuration"
  value = {
    billing_email                                  = github_organization_settings.org.billing_email
    company                                        = github_organization_settings.org.company
    blog                                           = github_organization_settings.org.blog
    email                                          = github_organization_settings.org.email
    location                                       = github_organization_settings.org.location
    description                                    = github_organization_settings.org.description
    has_organization_projects                      = github_organization_settings.org.has_organization_projects
    has_repository_projects                        = github_organization_settings.org.has_repository_projects
    default_repository_permission                  = github_organization_settings.org.default_repository_permission
    members_can_create_repositories                = github_organization_settings.org.members_can_create_repositories
    members_can_create_public_repositories         = github_organization_settings.org.members_can_create_public_repositories
    members_can_create_private_repositories        = github_organization_settings.org.members_can_create_private_repositories
    advanced_security_enabled_for_new_repositories = github_organization_settings.org.advanced_security_enabled_for_new_repositories
    dependabot_alerts_enabled_for_new_repositories = github_organization_settings.org.dependabot_alerts_enabled_for_new_repositories
    dependency_graph_enabled_for_new_repositories  = github_organization_settings.org.dependency_graph_enabled_for_new_repositories
    secret_scanning_enabled_for_new_repositories   = github_organization_settings.org.secret_scanning_enabled_for_new_repositories
  }
}
