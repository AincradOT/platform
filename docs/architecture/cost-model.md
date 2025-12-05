# Cost Model

## Overview

This platform uses GCP **only** for:

- Terraform state storage
- Secret management
- Database backups/blob storage
- Shared services (logging/monitoring)

**Application infrastructure** (VMs, game servers, web servers) runs on cheaper providers (Hetzner, OVH, etc.).

This keeps GCP costs minimal while providing enterprise-grade state management and secrets.

## Monthly Cost Estimate

**For a small Open Tibia server (3-10 developers, 2 environments):**

| Service | Usage | Monthly Cost |
|---------|-------|--------------|
| **GCS State Bucket** | ~1GB storage, <1000 operations/month | $0.02 - $0.10 |
| **Secret Manager** | ~10 secrets, ~1000 accesses/month | $0.06 - $0.30 |
| **Projects** | 4 projects (bootstrap, shared, dev, prod) | $0.00 (free) |
| **Cloud Logging** | ~1GB logs/month | $0.50 - $1.00 |
| **Cloud Monitoring** | Minimal metrics | $0.00 - $0.50 |
| **Egress** | State downloads, minimal | $0.10 - $0.50 |
| **Cloudflare** | Domain registration (~$25/year) | $2.08 |
| **Cloudflare** | DNS, TLS, DDoS protection | $0.00 (free) |
| **GitHub Team** | 3 developers, private repos, container registry | $12.00 |
| **Total** | | **~$15 - $18/month** |

!!! note
    GitHub Team plan ($4/user/month) required for private repos with container registry.
    Includes 3000 Actions minutes/month and 2GB packages storage.

## Cost Optimization

### Already optimized

- Single state bucket (not per-environment)
- Google-managed encryption (no KMS key costs)
- Minimal logging retention (7-30 days)
- No NAT Gateway or VPC
- Cloudflare free tier for web services
- GitHub free tier for small teams

### Keep costs low

- Don't store large files in GCS (use cheap blob storage for backups)
- Minimize Secret Manager API calls (cache secrets in application for 5+ minutes)
- Use lifecycle rules to delete old state versions (keep only last 50)
- Keep logging minimal (don't log every terraform operation)

## Cost Monitoring

### Set up billing alerts

```bash
# Create budget alert at $5/month
gcloud billing budgets create \
  --billing-account=<billing-account-id> \
  --display-name="Platform Budget Alert" \
  --budget-amount=5USD
```

### Check costs monthly

```bash
# View current month's costs
gcloud billing accounts list
# Then view in console: https://console.cloud.google.com/billing
```


## Cost Projection

### As team grows

| Team Size | Environments | Monthly Platform Cost |
|-----------|--------------|----------------------|
| 1-3 devs | dev, prod | $14-17 |
| 4-10 devs | dev, staging, prod | $30-40 |
| 11-20 devs | multiple staging environments | $60-90 |

## Summary

**Platform cost: ~$15-18/month**

Breakdown:
- GCP: ~$1-3/month
- Cloudflare domain: ~$2/month
- GitHub Team: $12/month (3 devs)
- Cloudflare services: $0

!!! note
    GitHub Team required for private repos with container registry.
    For public repos only, GitHub is free (saves $12/month).
