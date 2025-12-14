provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "zone" {
  name = var.zone_name
}

locals {
  zone_id = data.cloudflare_zone.zone.id
}

# Baseline HTTPS posture for the zone. Applies only to proxied HTTP/HTTPS
# traffic. Non-proxied A records (proxied = false), including the TCP game
# service on ports 7171/7172, are not affected by these settings.
resource "cloudflare_zone_settings_override" "zone" {
  zone_id = local.zone_id

  settings {
    ssl                      = "full"
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    min_tls_version          = "1.2"
  }
}
