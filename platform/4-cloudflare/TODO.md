# Cloudflare Platform Module - NOT PLANNED

## Decision: Application Responsibility

Cloudflare resources are **application-managed, not platform-managed**.

### Rationale

- DNS records are application-specific (lifecycle tied to application)
- TLS certificates are application-specific
- API tokens should be scoped per application for security
- Cloudflare provider in platform adds coupling without benefit

### Platform Provides

- Zone ID documentation (manual Cloudflare account setup)
- Secret Manager API enabled (applications store their tokens)
- Example pattern in architecture/cloudflare.md

### Applications Provide

- Cloudflare API tokens (stored in Secret Manager)
- DNS record terraform resources
- TLS origin certificate management
- CDN/firewall rules as needed

## Implementation: None Required

This module will remain empty. See README.md for application self-service pattern.
