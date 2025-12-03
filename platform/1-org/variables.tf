variable "org_id" {
  description = "The organization ID (numeric)."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID (e.g. XXXXXX-YYYYYY-ZZZZZZ)."
  type        = string
}

variable "logging_project_id" {
  description = "Unique project ID for the central logging/monitoring project (e.g. platform-logging)."
  type        = string
}

variable "logging_project_name" {
  description = "Human-friendly name for the logging project."
  type        = string
  default     = "Platform Logging"
}

variable "gcp_logging_viewers_group" {
  description = "Group email that can view logs/metrics (e.g., logging-viewers@example.com)."
  type        = string
  default     = null
}

variable "gcp_org_admins_group" {
  description = "Group email for org-level admins (e.g., org-admins@example.com)."
  type        = string
  default     = null
}

variable "gcp_billing_admins_group" {
  description = "Group email for billing admins on the billing account (e.g., billing-admins@example.com)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Optional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
