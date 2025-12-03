variable "org_id" {
  description = "The organization ID (numeric)."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID (e.g. XXXXXX-YYYYYY-ZZZZZZ)."
  type        = string
}

variable "bootstrap_project_id" {
  description = "Globally-unique project ID for the bootstrap project (e.g. foundations-bootstrap)."
  type        = string
}

variable "bootstrap_project_name" {
  description = "Human-friendly project name."
  type        = string
  default     = "Foundations Bootstrap"
}

variable "create_bootstrap_project" {
  description = "If true, create the bootstrap project in this stage. Set false if you pre-created it via CLI."
  type        = bool
  default     = true
}

variable "state_bucket_name" {
  description = "Globally-unique GCS bucket name for Terraform remote state."
  type        = string
}

variable "create_state_bucket" {
  description = "If true, create the state bucket in this stage. Set false if you pre-created it and are using a remote backend on day 0."
  type        = bool
  default     = true
}

variable "state_bucket_project_id" {
  description = "Project ID to host the state bucket if creating it via Terraform. Defaults to the bootstrap project."
  type        = string
  default     = ""
}

variable "location" {
  description = "Location/region for the state bucket (e.g. US, EU, australia-southeast1)."
  type        = string
  default     = "US"
}

variable "labels" {
  description = "Optional labels to apply to created resources."
  type        = map(string)
  default     = {}
}
