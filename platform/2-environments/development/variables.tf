variable "billing_account_id" {
  description = "Billing account to attach to the development project."
  type        = string
}

variable "folder_id" {
  description = "Folder resource name or numeric ID for dev, e.g. folders/123456789 or 123456789."
  type        = string
}

variable "logging_project_id" {
  description = "Project ID of the central logging/monitoring project (from 1-foundation outputs)."
  type        = string
}

variable "dev_project_id" {
  description = "Unique project ID for development (e.g. sao-dev)."
  type        = string
}

variable "dev_project_name" {
  description = "Human-friendly name for development project."
  type        = string
  default     = "Development"
}

variable "gcp_platform_devs_group" {
  description = "Group email for platform developers with elevated dev permissions (e.g. platform-devs@example.com)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Optional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
