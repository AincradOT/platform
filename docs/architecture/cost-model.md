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
| **Total** | | **~$1 - $3/month** |

**If using Cloud SQL for database** (optional, future):

- Cloud SQL (db-f1-micro): ~$7-10/month
- Total would increase to ~$8-13/month

## Cost Optimization

**Already optimized:**

- Single state bucket (not per-environment)
- Google-managed encryption (no KMS key costs)
- Minimal logging retention (7-30 days)
- No NAT Gateway or VPC (not needed for state/secrets only)
- Free tier projects (no project charges)

**Keep costs low:**

- Don't store large files in GCS (use cheap blob storage for backups)
- Minimize Secret Manager API calls (cache secrets in application for 5+ minutes)
- Use lifecycle rules to delete old state versions (keep only last 50)
- Keep logging minimal (don't log every terraform operation)

## Cost Monitoring

**Set up billing alerts:**

```bash
# Create budget alert at $5/month
gcloud billing budgets create \
  --billing-account=<billing-account-id> \
  --display-name="Platform Budget Alert" \
  --budget-amount=5USD
```

**Check costs monthly:**

```bash
# View current month's costs
gcloud billing accounts list
# Then view in console: https://console.cloud.google.com/billing
```

## Comparison: Why Not All-In on GCP?

**If we ran VMs on GCP:**

- e2-small (2vCPU, 2GB) in europe-west3: ~$15/month
- 50GB SSD: ~$8/month
- Total per VM: ~$23/month
- For 2 environments: **~$46/month**

**Alternative providers:**

- Hetzner CX21 (2vCPU, 4GB, 40GB SSD): ~€5/month (~$5.50)
- For 2 environments: **~$11/month**

**Savings: ~$35/month** by keeping VMs off GCP.

**Trade-off:**

- More complexity (GCP for platform, Hetzner for workloads)
- But appropriate for small teams on tight budgets
- GCP provides value where it matters (state management, secrets, monitoring)

## Free Tier Considerations

**GCP Free Tier (always free):**

- 5GB Cloud Storage (more than enough for state)
- Cloud Logging (first 50GB/month)
- Cloud Monitoring (basic metrics)

**Current usage stays within free tier** for state and secrets, so actual costs may be closer to **$0-1/month** for the first year.

## Cost Projection

**As team grows:**

| Team Size | Environments | Monthly GCP Cost |
|-----------|--------------|------------------|
| 1-3 devs | dev, prod | $1-2 |
| 3-10 devs | dev, staging, prod | $2-5 |
| 10-20 devs | multiple staging environments | $5-10 |

**If migrating VMs to GCP later:**

- Add ~$20-30/month per environment
- Only do this if budget allows or revenue justifies it

## Summary

**Platform cost: ~$1-3/month**

This is negligible for what it provides:

- Centralized state management
- Secure secrets storage
- Logging and monitoring
- Professional-grade platform foundation

The cost is justified even for hobby/community projects because it prevents much more expensive mistakes (lost state, exposed secrets, infrastructure drift).
