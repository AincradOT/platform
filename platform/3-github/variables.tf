# ====================================================================
# Top Level Variable Definitions
# This file contains all variable definitions used across the entire
# GitHub infrastructure configuration. Variables are organized by
# domain and include comprehensive descriptions and validation where
# appropriate. These variables are passed down to the respective modules.
# ====================================================================

variable "shared_project_id" {
  description = "Shared services project ID where Secret Manager secrets are stored (from 1-org output)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,28}[a-z0-9]$", var.shared_project_id))
    error_message = "shared_project_id must be 5-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

variable "github_organization" {
  description = "GitHub organization name where resources will be created"
  type        = string
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
    billing_email                                  = optional(string)
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
  default = {}
}

variable "teams" {
  description = "Teams configuration including members and permissions"
  type = map(object({
    description = string
    privacy     = optional(string, "closed")
    members     = optional(list(string), [])
    maintainers = optional(list(string), [])
  }))
  # No default - must be provided in terraform.tfvars
}
