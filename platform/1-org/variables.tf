# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
# These MUST be provided in terraform.tfvars

variable "org_id" {
  description = "GCP organization ID."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID."
  type        = string
}

variable "logging_project_id" {
  description = "Unique project ID for central logging/monitoring (e.g., sao-shared-logging)."
  type        = string
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
}

variable "gcp_org_admins_group" {
  description = "Group email for org-level project creation (e.g., platform-admins@example.com)."
  type        = string
  default     = null
}

variable "gcp_billing_admins_group" {
  description = "Group email for billing admins on the billing account (e.g., billing-admins@example.com)."
  type        = string
  default     = null
}

# ============================================================================
# PLATFORM DEFAULTS
# ============================================================================
# These define the golden path. Override only for testing/development.

variable "logging_project_name" {
  description = "Display name for logging project."
  type        = string
  default     = "Shared Logging"
}

variable "labels" {
  description = "Additional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
