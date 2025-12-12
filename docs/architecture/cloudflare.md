# Cloudflare

Cloudflare provides [DNS](https://www.cloudflare.com/learning/dns/what-is-dns/), [TLS certificates](https://www.cloudflare.com/learning/ssl/what-is-ssl/), and edge protection for web services.

## Platform vs Application Responsibility

**Platform provides:**
- Zone ID stored in Secret Manager
- API token stored in Secret Manager
- Domain registration and nameserver configuration

**Applications manage:**
- DNS records for their services
- TLS origin certificates
- CDN configuration
- Firewall rules specific to their applications

This document describes application-level Cloudflare usage patterns. The platform does not manage DNS records or application-specific Cloudflare resources.

## What it provides

* DNS management for primary domain and subdomains
* Free TLS certificates with automatic renewal
* [DDoS protection](https://www.cloudflare.com/learning/ddos/what-is-a-ddos-attack/) for proxied services
* [CDN](https://www.cloudflare.com/learning/cdn/what-is-a-cdn/) for static assets (rarely needed for Open Tibia)

## Getting Your Zone ID

The Cloudflare Zone ID is stored in Secret Manager during `1-org` terraform apply.

**During initial setup (1-org terraform):**

1. Log in to the [Cloudflare dashboard](https://dash.cloudflare.com/)
2. Select your domain from the list
3. Scroll down on the Overview page
4. Find **Zone ID** in the API section on the right sidebar
5. Copy the Zone ID (format: 32-character hexadecimal string like `1234567890abcdef1234567890abcdef`)
6. Add to `platform/1-org/terraform.tfvars`:
   ```hcl
   cloudflare_zone_id = "1234567890abcdef1234567890abcdef"
   ```

**For application infrastructure:**

Applications read the Zone ID from Secret Manager at runtime using data sources:

```hcl
data "google_secret_manager_secret_version" "cloudflare_zone_id" {
  project = var.shared_project_id
  secret  = "cloudflare-zone-id"
}

resource "cloudflare_record" "example" {
  zone_id = data.google_secret_manager_secret_version.cloudflare_zone_id.secret_data
  # ...
}
```

This eliminates the need to duplicate the Zone ID across multiple application repositories.

## DNS Self-Service Pattern

Application repositories manage their own DNS records using [Cloudflare Terraform provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs):

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

### Why this works

* No manual DNS updates or platform repo PRs
* Stack destroy automatically removes DNS records
* Application owns its full infrastructure lifecycle
* Follows infrastructure-as-code principles

## TLS for Web Services

### Origin Certificates

1. Generate in Cloudflare dashboard (15 year validity)
2. Store in [Secret Manager](state-management.md)
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

!!! danger
    Never commit API tokens.
    Use zone-scoped tokens, not account-wide.
