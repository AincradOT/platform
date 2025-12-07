variable "github_app_id" {
  description = "GitHub App ID for token generation"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App installation ID for the target organization"
  type        = string
}

variable "github_app_pem_file" {
  description = "Path to GitHub App PEM file for authentication"
  type        = string
  sensitive   = true
}
