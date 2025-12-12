variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "org_settings" {
  description = "Organization-wide settings and policies"
  type = object({
    billing_email                                  = string
    company                                        = optional(string)
    blog                                           = optional(string)
    email                                          = optional(string)
    twitter_username                               = optional(string)
    location                                       = optional(string)
    description                                    = optional(string)
    has_organization_projects                      = optional(bool, true)
    has_repository_projects                        = optional(bool, false)
    default_repository_permission                  = optional(string, "read")
    members_can_create_repositories                = optional(bool, false)
    members_can_create_public_repositories         = optional(bool, false)
    members_can_create_private_repositories        = optional(bool, false)
    members_can_create_internal_repositories       = optional(bool, false)
    members_can_create_pages                       = optional(bool, true)
    members_can_create_public_pages                = optional(bool, true)
    members_can_create_private_pages               = optional(bool, false)
    members_can_fork_private_repositories          = optional(bool, false)
    web_commit_signoff_required                    = optional(bool, false)
    advanced_security_enabled_for_new_repositories = optional(bool, false)
    dependabot_alerts_enabled_for_new_repositories = optional(bool, true)
    dependency_graph_enabled_for_new_repositories  = optional(bool, true)
    secret_scanning_enabled_for_new_repositories   = optional(bool, false)
  })
}
