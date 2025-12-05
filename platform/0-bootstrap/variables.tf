variable "org_id" {
  description = "GCP organization ID."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID."
  type        = string
}

variable "project_name" {
  description = "Project name (e.g. 'sao-platform'). Project ID will be auto-generated with '-bootstrap' suffix."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally-unique GCS bucket name for Terraform state."
  type        = string
}

variable "location" {
  description = "GCS bucket location."
  type        = string
  default     = "europe-west3"
}

variable "labels" {
  description = "Labels to apply to resources."
  type        = map(string)
  default     = {}
}
