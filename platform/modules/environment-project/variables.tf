# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

variable "billing_account_id" {
  description = "Billing account ID."
  type        = string
}

variable "folder_id" {
  description = "Folder ID for this environment (e.g. folders/123456789)."
  type        = string
}

variable "logging_project_id" {
  description = "Central logging project ID for metrics scope attachment."
  type        = string
}

variable "project_id" {
  description = "Unique project ID for this environment (e.g. sao-dev)."
  type        = string
}

variable "environment_name" {
  description = "Environment name for labeling (e.g. development, production)."
  type        = string
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================

variable "project_display_name" {
  description = "Display name for the project. Defaults to project_id if not provided."
  type        = string
  default     = ""
}

variable "ci_service_account" {
  description = "CI service account email to grant editor role."
  type        = string
  default     = null
}

variable "iam_bindings" {
  description = "Additional IAM bindings. Map key is identifier, value contains role and member."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}

variable "labels" {
  description = "Additional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
