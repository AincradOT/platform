# Cloudflare zone-level HTTPS posture for sword-art.online.
# DNS records (including game, traefik, grafana, etc.) remain managed in the
# game-infra repo. This config only sets baseline zone policy.
#
# Supply the Cloudflare API token via TF_VAR_cloudflare_api_token, a tfvars
# file kept out of version control, or workspace/CI variables.
module "sword_art_online_zone" {
  source = "../modules/cloudflare_zone"

  zone_name              = "sword-art.online"
  cloudflare_api_token   = var.cloudflare_api_token
}
