output "zone_id" {
  description = "Cloudflare zone ID for sword-art.online."
  value       = module.sword_art_online_zone.zone_id
}

output "zone_settings_override_id" {
  description = "Identifier for the applied zone settings override."
  value       = module.sword_art_online_zone.zone_settings_override_id
}
