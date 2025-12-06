# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
# These MUST be provided in terraform.tfvars

variable "billing_account_id" {
  description = "Billing account ID (from 0-bootstrap outputs)."
  type        = string
}

variable "folder_id" {
  description = "Production folder ID from 1-org outputs (e.g. folders/123456789)."
  type        = string
}

variable "logging_project_id" {
  description = "Central logging project ID (from 1-org outputs)."
  type        = string
}

variable "prod_project_id" {
  description = "Unique project ID for production (e.g. sao-prod)."
  type        = string
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================
# These enable optional features

variable "prod_ci_service_account" {
  description = "Prod CI service account email (from 1-org outputs) for granting editor role."
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
