# Cloudflare

Cloudflare provides DNS, TLS certificates, and edge protection for web services.

## What it provides

* DNS management for primary domain and subdomains
* Free TLS certificates with automatic renewal
* DDoS protection for proxied services
* CDN for static assets (rarely needed for Open Tibia)

## DNS Self-Service Pattern

Application repositories manage their own DNS records using Cloudflare Terraform provider:

```hcl
resource "cloudflare_record" "game" {
  zone_id = var.cloudflare_zone_id
  name    = "game"
  type    = "A"
  value   = var.server_ip
  proxied = false
}
```

!!! note
    Application terraform includes Cloudflare provider.
    Platform provides zone_id and API token.
    DNS records lifecycle-managed with the stack.

### Benefits

* No manual DNS updates or platform repo PRs
* Stack destroy automatically removes DNS records
* Application owns its full infrastructure lifecycle
* Follows infrastructure-as-code principles

## TLS for Web Services

### Origin Certificates

1. Generate in Cloudflare dashboard (15 year validity)
2. Store in Secret Manager
3. Configure web server to use origin cert
4. Set SSL mode to "Full (strict)"

## Game Server TCP Exposure

!!! warning
    Game servers run on TCP layer 4 (ports 7171-7172).
    Cloudflare free tier does not support TCP proxying.
    Cloudflare Spectrum costs ~$0.01/GB after 10TB.

### Decision

Game servers are exposed directly (not proxied):

- Clients connect to origin IP
- DNS records set to "DNS only" (gray cloud)
- No edge DDoS protection for game traffic

### Mitigation

- Separate IPs for web vs game servers
- Rate limiting in game server config and iptables
- Monitor for traffic anomalies
- Keep backup IP available

!!! note
    Common pattern for game servers (Minecraft, CS:GO).
    Cost optimization, not security failure.
    Acceptable for small-medium communities with proper VM security.

## API tokens

Cloudflare API tokens are managed by platform repository:

- Scoped to specific zones
- Limited permissions (DNS Edit, SSL/TLS Read)
- Stored in Secret Manager
- Available to application repositories via terraform outputs
- Rotated every 6 months

!!! danger
    Never commit API tokens.
    Use zone-scoped tokens, not account-wide.
