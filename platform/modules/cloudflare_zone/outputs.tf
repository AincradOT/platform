output "zone_id" {
  description = "The Cloudflare zone ID resolved from the provided zone name."
  value       = local.zone_id
}

output "zone_settings_override_id" {
  description = "Identifier for the zone settings override resource."
  value       = cloudflare_zone_settings_override.zone.id
}
