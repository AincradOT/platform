# ====================================================================
# GitHub Infrastructure Management
# This is the top-level configuration that orchestrates all GitHub
# infrastructure modules including organization settings, teams,
# repositories, secrets, and branch protection policies.
# All modules are configured through this main file with consistent
# variable passing and dependency management.
# ====================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Read GitHub App credentials from Secret Manager
data "google_secret_manager_secret_version" "github_app_id" {
  project = var.shared_project_id
  secret  = "github-app-id"
}

data "google_secret_manager_secret_version" "github_app_installation_id" {
  project = var.shared_project_id
  secret  = "github-app-installation-id"
}

data "google_secret_manager_secret_version" "github_app_private_key" {
  project = var.shared_project_id
  secret  = "github-app-private-key"
}

# Configure the GitHub Provider using GitHub App credentials from Secret Manager
provider "github" {
  app_auth {
    id              = data.google_secret_manager_secret_version.github_app_id.secret_data
    installation_id = data.google_secret_manager_secret_version.github_app_installation_id.secret_data
    pem_file        = data.google_secret_manager_secret_version.github_app_private_key.secret_data
  }
  owner = var.github_organization
}

# Data source to get organization information
data "github_organization" "org" {
  name = var.github_organization
}

data "github_app_token" "installation" {
  app_id          = data.google_secret_manager_secret_version.github_app_id.secret_data
  installation_id = data.google_secret_manager_secret_version.github_app_installation_id.secret_data
  pem_file        = data.google_secret_manager_secret_version.github_app_private_key.secret_data
}

# Common repository settings shared across all repositories
locals {
  common_repo_settings = {
    topics                 = []
    visibility             = "private"
    has_issues             = true
    has_projects           = false
    has_wiki               = false
    has_downloads          = false
    delete_branch_on_merge = true

    allow_squash_merge = true
    allow_merge_commit = false
    allow_rebase_merge = false
    allow_auto_merge   = true

    squash_merge_commit_title   = "PR_TITLE"
    squash_merge_commit_message = "PR_BODY"
    merge_commit_title          = "MERGE_MESSAGE"
    merge_commit_message        = "PR_TITLE"
  }

  # Standard labels for all repositories
  standard_labels = [
    { name = "bug", color = "d73a4a", description = "Something isn't working" },
    { name = "enhancement", color = "a2eeef", description = "New feature or request" },
    { name = "documentation", color = "0075ca", description = "Improvements or additions to documentation" },
    { name = "good first issue", color = "7057ff", description = "Good for newcomers" },
    { name = "help wanted", color = "008672", description = "Extra attention is needed" },
    { name = "duplicate", color = "cfd3d7", description = "This issue or pull request already exists" },
    { name = "wontfix", color = "ffffff", description = "This will not be worked on" },
    { name = "priority/high", color = "d93f0b", description = "High priority issue" },
    { name = "priority/medium", color = "fbca04", description = "Medium priority issue" },
    { name = "priority/low", color = "0e8a16", description = "Low priority issue" }
  ]
}

# Teams Module
module "teams" {
  source              = "./modules/teams"
  teams               = var.teams
  github_organization = var.github_organization
}

# Secrets Module
module "secrets" {
  source                     = "./modules/secrets"
  github_app_id              = data.google_secret_manager_secret_version.github_app_id.secret_data
  github_app_installation_id = data.google_secret_manager_secret_version.github_app_installation_id.secret_data
  github_app_pem_file        = data.google_secret_manager_secret_version.github_app_private_key.secret_data
}
