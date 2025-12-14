variable "cloudflare_api_token" {
  description = "Cloudflare API token with permissions to manage the sword-art.online zone. Recommended to supply via TF_VAR_cloudflare_api_token or workspace/CI variable, not committed to source control."
  type        = string
  sensitive   = true
}
