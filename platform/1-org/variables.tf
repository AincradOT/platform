# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
# These MUST be provided in terraform.tfvars

variable "org_id" {
  description = "GCP organization ID."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.org_id))
    error_message = "org_id must be a numeric organization ID (e.g., 123456789012)"
  }
}

variable "billing_account_id" {
  description = "Billing account ID."
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must be in format ABCDEF-123456-ABCDEF"
  }
}

variable "shared_project_id" {
  description = "Unique project ID for shared services (e.g., aincrad-shared)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,28}[a-z0-9]$", var.shared_project_id))
    error_message = "shared_project_id must be 5-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens"
  }
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

# ============================================================================
# PLATFORM DEFAULTS
# ============================================================================
# These define the golden path. Override only for testing/development.

variable "shared_project_name" {
  description = "Display name for shared services project."
  type        = string
  default     = "Shared Services"
}

variable "labels" {
  description = "Additional labels to apply to resources."
  type        = map(string)
  default     = {}
}

# GitHub App credentials for dual storage (GitHub org secrets + GCP Secret Manager)
# Only required for initial bootstrap to populate GCP Secret Manager
# After initial sync, these can be omitted from terraform.tfvars
variable "github_app_id" {
  description = "GitHub App ID. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "github_app_private_key" {
  description = "GitHub App private key (PEM file contents). Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

# Cloudflare API token for infrastructure management
# Only required for initial bootstrap to populate GCP Secret Manager
variable "cloudflare_api_token" {
  description = "Cloudflare API token. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

# Cloudflare Zone ID for DNS management
# Only required for initial bootstrap to populate GCP Secret Manager
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for your domain. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

# SOPS (age) key for SOPS-encrypted tfvars across application/service repos
# Only required for initial bootstrap to populate GCP Secret Manager
variable "org_sops_age_key" {
  description = "Organisation-wide age private key for SOPS (full contents of a .sops.age.key file). Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

# SSH connection details for OVH VPS machines
# Only required for initial bootstrap to populate GCP Secret Manager
variable "dev_vps_ssh_host" {
  description = "Development VPS SSH hostname or IP address. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "dev_vps_ssh_user" {
  description = "Development VPS SSH username. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "dev_vps_ssh_password" {
  description = "Development VPS SSH password. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "dev_vps_ssh_private_key" {
  description = "Development VPS SSH private key (PEM format). Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "prod_vps_ssh_host" {
  description = "Production VPS SSH hostname or IP address. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "prod_vps_ssh_user" {
  description = "Production VPS SSH username. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = false
  default     = null
}

variable "prod_vps_ssh_password" {
  description = "Production VPS SSH password. Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "prod_vps_ssh_private_key" {
  description = "Production VPS SSH private key (PEM format). Only needed for initial bootstrap to sync to Secret Manager."
  type        = string
  sensitive   = true
  default     = null
}
