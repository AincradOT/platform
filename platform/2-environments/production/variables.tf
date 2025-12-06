# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
# These MUST be provided in terraform.tfvars

variable "billing_account_id" {
  description = "Billing account ID (from 0-bootstrap outputs)."
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must be in format ABCDEF-123456-ABCDEF"
  }
}

variable "folder_id" {
  description = "Production folder ID from 1-org outputs (e.g. folders/123456789). If not provided, will be pulled from 1-org remote state."
  type        = string
  default     = null
}

variable "shared_project_id" {
  description = "Shared services project ID (from 1-org outputs). If not provided, will be pulled from 1-org remote state."
  type        = string
  default     = null

  validation {
    condition     = var.shared_project_id == null || can(regex("^[a-z][a-z0-9-]{3,28}[a-z0-9]$", var.shared_project_id))
    error_message = "shared_project_id must be 5-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

variable "prod_project_id" {
  description = "Unique project ID for production (e.g. sao-prod)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,28}[a-z0-9]$", var.prod_project_id))
    error_message = "prod_project_id must be 5-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

variable "state_bucket_name" {
  description = "GCS state bucket name (from 0-bootstrap output) for remote state data source."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,62}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be 5-63 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================
# These enable optional features

variable "prod_ci_service_account" {
  description = "Prod CI service account email (from 1-org outputs) for granting editor role. If not provided, will be pulled from 1-org remote state."
  type        = string
  default     = null
}

variable "gcp_platform_viewers_group" {
  description = "Group email for viewer access in production (grants roles/viewer)."
  type        = string
  default     = null
}

# ============================================================================
# PLATFORM DEFAULTS
# ============================================================================
# These define the golden path. Override only for testing/development.

variable "prod_project_name" {
  description = "Display name for production project."
  type        = string
  default     = "Production"
}

variable "labels" {
  description = "Additional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
