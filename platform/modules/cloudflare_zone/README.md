## Cloudflare Zone Baseline Module

This module locates a Cloudflare zone by name and applies baseline HTTPS posture via `cloudflare_zone_settings_override`:

- SSL mode set to Full (origin expected to support HTTPS)
- Always Use HTTPS enabled for proxied HTTP traffic
- TLS minimum version 1.2
- HTTP/2 and HTTP/3 are handled automatically by Cloudflare edge (not set here because those settings are read-only in the API)
- Automatic HTTPS rewrites enabled

Scope and exclusions:

- Does **not** create or manage DNS records.
- Does **not** manage origin certificates.
- Applies only to proxied HTTP/HTTPS requests that traverse Cloudflare. Non-proxied A records (`proxied = false`), including the TCP game service on ports 7171/7172, are unaffected.
