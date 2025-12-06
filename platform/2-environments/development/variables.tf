# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
# These MUST be provided in terraform.tfvars

variable "billing_account_id" {
  description = "Billing account ID (from 0-bootstrap outputs)."
  type        = string
}

variable "folder_id" {
  description = "Development folder ID from 1-org outputs (e.g. folders/123456789)."
  type        = string
}

variable "shared_project_id" {
  description = "Shared services project ID (from 1-org outputs)."
  type        = string
}

variable "dev_project_id" {
  description = "Unique project ID for development (e.g. sao-dev)."
  type        = string
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================
# These enable optional features

variable "dev_ci_service_account" {
  description = "Dev CI service account email (from 1-org outputs) for granting editor role."
  type        = string
  default     = null
}

variable "gcp_platform_devs_group" {
  description = "Group email for platform developers (grants compute.instanceAdmin.v1)."
  type        = string
  default     = null
}

# ============================================================================
# PLATFORM DEFAULTS
# ============================================================================
# These define the golden path. Override only for testing/development.

variable "dev_project_name" {
  description = "Display name for development project."
  type        = string
  default     = "Development"
}

variable "labels" {
  description = "Additional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
