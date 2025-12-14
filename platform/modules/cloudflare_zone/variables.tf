variable "zone_name" {
  description = "Cloudflare zone name to manage (e.g. sword-art.online)."
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token scoped to manage the target zone."
  type        = string
  sensitive   = true
}
