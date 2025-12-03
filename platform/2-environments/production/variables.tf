variable "billing_account_id" {
  description = "Billing account to attach to the production project."
  type        = string
}

variable "folder_id" {
  description = "Folder resource name or numeric ID for Production, e.g. folders/123456789 or 123456789."
  type        = string
}

variable "logging_project_id" {
  description = "Project ID of the central logging/monitoring project (from 1-org outputs)."
  type        = string
}

variable "prod_project_id" {
  description = "Unique project ID for production (e.g. platform-prod)."
  type        = string
}

variable "prod_project_name" {
  description = "Human-friendly name for production project."
  type        = string
  default     = "Platform Production"
}

variable "gcp_platform_viewers_group" {
  description = "Group email with viewer permissions in production (e.g. platform-viewers@example.com)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Optional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
