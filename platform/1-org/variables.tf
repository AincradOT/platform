# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
# These MUST be provided in terraform.tfvars

variable "org_id" {
  description = "GCP organization ID."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.org_id))
    error_message = "org_id must be a numeric organization ID (e.g., 123456789012)"
  }
}

variable "billing_account_id" {
  description = "Billing account ID."
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must be in format ABCDEF-123456-ABCDEF"
  }
}

variable "shared_project_id" {
  description = "Unique project ID for shared services (e.g., aincrad-shared)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,28}[a-z0-9]$", var.shared_project_id))
    error_message = "shared_project_id must be 5-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================
# These enable optional features

variable "state_bucket_name" {
  description = "Name of the GCS state bucket (from 0-bootstrap). Required for granting CI service accounts access to state."
  type        = string
  default     = null
}

variable "gcp_logging_viewers_group" {
  description = "Group email for logging/monitoring viewer access (e.g., logging-viewers@example.com)."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_logging_viewers_group == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.gcp_logging_viewers_group))
    error_message = "gcp_logging_viewers_group must be a valid email address"
  }
}

variable "gcp_org_admins_group" {
  description = "Group email for org-level project creation (e.g., platform-admins@example.com)."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_org_admins_group == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.gcp_org_admins_group))
    error_message = "gcp_org_admins_group must be a valid email address"
  }
}

variable "gcp_billing_admins_group" {
  description = "Group email for billing admins on the billing account (e.g., billing-admins@example.com)."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_billing_admins_group == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.gcp_billing_admins_group))
    error_message = "gcp_billing_admins_group must be a valid email address"
  }
}

# ============================================================================
# PLATFORM DEFAULTS
# ============================================================================
# These define the golden path. Override only for testing/development.

variable "shared_project_name" {
  description = "Display name for shared services project."
  type        = string
  default     = "Shared Services"
}

variable "labels" {
  description = "Additional labels to apply to resources."
  type        = map(string)
  default     = {}
}

# GitHub App credentials for dual storage (GitHub org secrets + GCP Secret Manager)
# Only required for initial bootstrap to populate GCP Secret Manager
# After initial sync, these can be omitted from terraform.tfvars
variable "github_app_id" {
  description = "GitHub App ID. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "github_app_private_key" {
  description = "GitHub App private key (PEM file contents). Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

# Cloudflare API token for infrastructure management
# Only required for initial bootstrap to populate GCP Secret Manager
variable "cloudflare_api_token" {
  description = "Cloudflare API token. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}
