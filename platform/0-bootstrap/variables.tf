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

variable "project_name" {
  description = "Project name (e.g., sao). Used to generate project ID: {project_name}-bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,28}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 5-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

variable "state_bucket_name" {
  description = "Globally-unique GCS bucket name for Terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,62}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be 5-63 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
}

# ============================================================================
# PLATFORM DEFAULTS
# ============================================================================
# These define the golden path. Override only for testing/development.

variable "location" {
  description = "GCS bucket location for state storage."
  type        = string
  default     = "europe-west3"
}

variable "labels" {
  description = "Additional labels to apply to resources."
  type        = map(string)
  default     = {}
}
