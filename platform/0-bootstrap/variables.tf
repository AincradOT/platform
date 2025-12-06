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

variable "project_name" {
  description = "Project name (e.g. 'sao'). Project ID will be auto-generated with '-bootstrap' suffix."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally-unique GCS bucket name for Terraform state."
  type        = string
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
