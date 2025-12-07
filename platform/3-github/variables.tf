# ====================================================================
# Top Level Variable Definitions
# This file contains all variable definitions used across the entire
# GitHub infrastructure configuration. Variables are organized by
# domain and include comprehensive descriptions and validation where
# appropriate. These variables are passed down to the respective modules.
# ====================================================================

variable "github_app_id" {
  description = "GitHub App ID used for authentication"
  type        = string
  default     = ""
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID for the target organization"
  type        = string
  default     = ""
}

variable "github_app_pem_file" {
  description = "GitHub App private key in PEM format for authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_organization" {
  description = "GitHub organization name where resources will be created"
  type        = string
  default     = ""
}

variable "default_branch" {
  description = "Default branch name for repositories"
  type        = string
  default     = "master"
}

variable "enable_advanced_security" {
  description = "Enable GitHub Advanced Security features for the organization"
  type        = bool
  default     = false
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
  default = {
    billing_email = "qaush.gjokaj@gmail.com"
  }
}

variable "teams" {
  description = "Teams configuration including members and permissions"
  type = map(object({
    description = string
    privacy     = optional(string, "closed")
    members     = optional(list(string), [])
    maintainers = optional(list(string), [])
  }))
  default = {
    developers = {
      description = "Core devs"
      members     = ["qaushinio", "jordanhoare"]
    }
    admins = {
      description = "Organisation administrators & devs"
      members     = ["qaushinio", "jordanhoare"]
    }
  }
}
