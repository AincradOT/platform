# cloudflare

Cloudflare API token management for application self-service DNS.

## What this creates

- Cloudflare API token secret in Secret Manager (shared logging project)
- IAM bindings for dev/prod projects to read API token
- Zone ID output for application consumption

## Configuration

Update `backends.tf` with your state bucket from `0-bootstrap` output.

Create `terraform.tfvars`:

```hcl
shared_project_id        = "aincrad-shared"  # From 1-org output
cloudflare_zone_id       = "abc123def456"         # From Cloudflare dashboard
dev_ci_service_account   = "dev-ci@aincrad-shared.iam.gserviceaccount.com"
prod_ci_service_account  = "prod-ci@aincrad-shared.iam.gserviceaccount.com"
```

**After terraform apply:** Populate API token secret:

```bash
echo "your-cloudflare-api-token" | gcloud secrets versions add cloudflare-api-token \
  --project=aincrad-shared \
  --data-file=-
```

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `shared_project_id` | Shared services project ID (from 1-org output) | Yes |
| `cloudflare_zone_id` | Cloudflare zone ID from dashboard | Yes |
| `dev_ci_service_account` | Dev CI service account email (from 1-org output) | Yes |
| `prod_ci_service_account` | Prod CI service account email (from 1-org output) | Yes |

## Outputs

- `cloudflare_zone_id` - Cloudflare zone ID for application use
- `api_token_secret_name` - Secret Manager secret name for Cloudflare API token

## Notes

- API token stored in Secret Manager (centralized, encrypted, IAM-controlled)
- Token scoped to DNS Edit and SSL/TLS Read permissions only
- Token rotated every 6 months (manual via Cloudflare dashboard)
- Applications read token from Secret Manager to manage their DNS records
- Applications never commit tokens to repositories
- Self-service pattern: applications create/destroy DNS records with their infrastructure
- Game servers exposed directly (not proxied) due to TCP layer 4 requirements

### Application Usage Pattern

Applications read the token and manage their own DNS:

```hcl
# In application repository
data "google_secret_manager_secret_version" "cloudflare_token" {
  secret  = "cloudflare-api-token"
  project = var.shared_project_id
}

provider "cloudflare" {
  api_token = data.google_secret_manager_secret_version.cloudflare_token.secret_data
}

resource "cloudflare_record" "app" {
  zone_id = var.cloudflare_zone_id  # From platform output
  name    = "app"
  type    = "A"
  value   = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
  proxied = false
}
```

---

## Implementation Status

**Not yet implemented.** See `TODO.md` for technical and design requirements.
