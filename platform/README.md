# Platform Terraform

GCP organization and environment infrastructure for Open Tibia services.

## What this creates

- Bootstrap project with GCS state bucket
- Organizational folders (shared, dev, prod)
- Shared services project (logging, monitoring, service accounts, secrets)
- Development and production environment projects

**Directory structure:**

```text
platform/
  0-bootstrap/     # Bootstrap project and state bucket
  1-org/           # Organizational folders and shared services
  2-environments/
    development/   # Development environment project
    production/    # Production environment project
```

## Prerequisites

Complete the [Requirements](https://aincradot.github.io/platform/requirements/) before starting bootstrap. This includes:
- GCP organization with billing account
- GitHub organization and GitHub App
- Domain and DNS in Cloudflare
- Organization-level IAM roles granted to your account

**Local tools:**
- [`gcloud` CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.7 (last MPL version before license change)

**Additional Resources:**

- [GCP IAM Overview](https://cloud.google.com/iam/docs/overview) - Understanding roles and permissions
- [Terraform GCP Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs) - Resource reference
- [GCS Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) - State backend details

## Bootstrap procedure

### 1. Authenticate

```bash
gcloud auth application-default login
gcloud auth list  # Confirm correct account
```

### 2. Configure 0-bootstrap

Copy and edit the example file:

```bash
cp platform/0-bootstrap/example.terraform.tfvars platform/0-bootstrap/terraform.tfvars
```

Edit `terraform.tfvars` with your org ID, billing account, project name, and bucket name. See [0-bootstrap README](0-bootstrap/README.md) for variable details.

### 3. Run terraform for bootstrap

```bash
terraform -chdir=platform/0-bootstrap init
terraform -chdir=platform/0-bootstrap apply
```

**Verify bootstrap:**
```bash
# Confirm project exists
gcloud projects describe $(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)

# Confirm bucket exists with versioning
gsutil versioning get gs://$(terraform -chdir=platform/0-bootstrap output -raw state_bucket_name)
```

!!! warning "Stop if verification fails"
    Do not proceed to the next step if the bucket does not exist or versioning is not enabled.
    Fix the issue and re-run `terraform apply` before continuing.

### 4. Set quota project for ADC

Application default credentials need a quota project for API calls.

Set the bootstrap project as the quota project:

```bash
gcloud auth application-default set-quota-project $(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
```

### 5. Migrate bootstrap state to GCS

The bootstrap state is initially stored locally. Migrate it to GCS for consistency.

Edit `platform/0-bootstrap/backends.tf` and uncomment the GCS backend block:

**Before (commented out):**
```hcl
# terraform {
#   backend "gcs" {
#     bucket = "your-state-bucket-name"
#     prefix = "terraform/bootstrap"
#   }
# }
```

**After (uncommented with your bucket name):**
```hcl
terraform {
  backend "gcs" {
    bucket = "aincrad-tfstate"  # Use your bucket name from step 3 output
    prefix = "terraform/bootstrap"
  }
}
```

Migrate state:

```bash
terraform -chdir=platform/0-bootstrap init -migrate-state
# Type 'yes' when prompted to copy state from local to GCS
```

### 6. Configure 1-org

Copy and edit the example file:

```bash
cp platform/1-org/example.terraform.tfvars platform/1-org/terraform.tfvars
```

Update with your values. The `state_bucket_name` should match the output from 0-bootstrap. See [1-org README](1-org/README.md) for all available variables.

### 7. Enable required APIs

**Why:** Terraform uses Application Default Credentials (ADC) which bill API calls to the quota project. Even though `1-org` creates resources at the organization level, these APIs must be enabled in the bootstrap project (the quota project) for the API calls to succeed.

Enable the APIs in the bootstrap project:

```bash
gcloud services enable cloudidentity.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable orgpolicy.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable cloudresourcemanager.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable cloudbilling.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable iam.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable servicenetworking.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
```

!!! warning "Wait for API propagation"
APIs take 30-60 seconds to propagate after enabling. Running terraform immediately will fail with "API not enabled" errors.

**Wait before proceeding to step 8:**
```bash
# Wait for API propagation
sleep 60
```

**Verify APIs are enabled:**
```bash
# Verify critical APIs are enabled
gcloud services list --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id) --enabled | grep -E "cloudidentity|orgpolicy|cloudresourcemanager"
```

If verification shows APIs are not enabled, wait another 30 seconds and check again. If you skip this verification and encounter errors in step 8, retry `terraform apply`.

### 8. Run terraform for 1-org

```bash
terraform -chdir=platform/1-org init
terraform -chdir=platform/1-org apply
```

**Verify org structure:**
```bash
# List folders (replace 123456789012 with your org ID)
gcloud resource-manager folders list --organization=123456789012

# Verify shared services project
gcloud projects describe $(terraform -chdir=platform/1-org output -raw shared_project_id)

# Verify Cloud Identity groups were created
gcloud identity groups search --organization=$(terraform -chdir=platform/1-org output -raw org_id) --labels="cloudidentity.googleapis.com/groups.discussion_forum"
```

!!! warning "Stop if verification fails"
    Do not proceed if folders are not created or the shared services project does not exist.
    Review terraform output for errors and re-run `terraform apply` if needed.

### 9. Store API credentials in Secret Manager

!!! note "Single source of truth"
    API credentials (GitHub App, Cloudflare) are stored in GCP Secret Manager.
    Platform and application modules will read from Secret Manager to manage infrastructure.

Add the credentials to `platform/1-org/terraform.tfvars` using the values you noted during [manual setup](https://aincradot.github.io/platform/requirements/):

```hcl
# GitHub App credentials (use values from manual setup)
github_app_id              = "123456"  # Your App ID
github_app_installation_id = "12345678"  # Your Installation ID
github_app_private_key     = <<-EOT
-----BEGIN RSA PRIVATE KEY-----
[paste contents of your .pem file]
-----END RSA PRIVATE KEY-----
EOT

# Cloudflare API token and zone ID
cloudflare_api_token = "abc123def456ghi789jkl012mno345pqr678stu901vwx234yz"
cloudflare_zone_id   = "1234567890abcdef1234567890abcdef"

# VPS SSH credentials (optional - only if using VPS hosting for application infrastructure)
dev_vps_ssh_host     = "51.38.185.123"
dev_vps_ssh_user     = "ubuntu"
dev_vps_ssh_password = "temporary-password"  # Optional fallback auth
dev_vps_ssh_private_key = <<-EOT
-----BEGIN OPENSSH PRIVATE KEY-----
[paste contents of your SSH private key]
-----END OPENSSH PRIVATE KEY-----
EOT

prod_vps_ssh_host     = "51.38.186.234"
prod_vps_ssh_user     = "ubuntu"
prod_vps_ssh_password = "temporary-password"  # Optional fallback auth
prod_vps_ssh_private_key = <<-EOT
-----BEGIN OPENSSH PRIVATE KEY-----
[paste contents of your SSH private key]
-----END OPENSSH PRIVATE KEY-----
EOT
```

Run terraform to create the secrets:

```bash
terraform -chdir=platform/1-org apply
```

**Verify secrets were created:**
```bash
gcloud secrets list --project=$(terraform -chdir=platform/1-org output -raw shared_project_id)
```

You should see:
- `github-app-id`
- `github-app-installation-id`
- `github-app-private-key`
- `cloudflare-api-token`
- `cloudflare-zone-id`
- `dev-vps-ssh-host`, `dev-vps-ssh-user`, `dev-vps-ssh-password`, `dev-vps-ssh-private-key` (if provided)
- `prod-vps-ssh-host`, `prod-vps-ssh-user`, `prod-vps-ssh-password`, `prod-vps-ssh-private-key` (if provided)

**Clean up:**

After the initial sync:

1. Remove the API credentials from your `terraform.tfvars` file:
   ```hcl
   # Remove these lines after initial sync
   # github_app_id              = "123456"
   # github_app_installation_id = "12345678"
   # github_app_private_key     = <<-EOT ...
   # cloudflare_api_token       = "..."
   # cloudflare_zone_id         = "..."
   # dev_vps_ssh_host           = "..."
   # dev_vps_ssh_user           = "..."
   # dev_vps_ssh_password       = "..."
   # dev_vps_ssh_private_key    = <<-EOT ...
   # prod_vps_ssh_host          = "..."
   # prod_vps_ssh_user          = "..."
   # prod_vps_ssh_password      = "..."
   # prod_vps_ssh_private_key   = <<-EOT ...
   ```

2. Delete the local PEM file:
   ```bash
   rm ~/Downloads/platform-automation.*.private-key.pem
   ```

Secret Manager is now the single source of truth. The `lifecycle { ignore_changes }` policy ensures terraform won't try to update them on subsequent applies.

- The `3-github` module will read from Secret Manager and create GitHub organization secrets automatically
- Application modules will read the Cloudflare token from Secret Manager to manage their own DNS records

### 10. Configure and deploy environments

Copy and edit example files:

```bash
cp platform/2-environments/development/example.terraform.tfvars platform/2-environments/development/terraform.tfvars
```

Update with your values. Only `billing_account_id`, `state_bucket_name`, and `dev_project_id` are required. Values like `folder_id` and `shared_project_id` are **automatically pulled from 1-org remote state**. See [development README](2-environments/development/README.md) for details.

```bash
terraform -chdir=platform/2-environments/development init
terraform -chdir=platform/2-environments/development apply
```

**Verify dev environment:**
```bash
# Verify project
gcloud projects describe $(terraform -chdir=platform/2-environments/development output -raw dev_project_id)

# Verify APIs enabled
gcloud services list --project=$(terraform -chdir=platform/2-environments/development output -raw dev_project_id) --enabled
```

!!! warning "Stop if verification fails"
    Do not proceed if the dev project does not exist or required APIs are not enabled.
    Check terraform output for errors.

```bash
cp platform/2-environments/production/example.terraform.tfvars platform/2-environments/production/terraform.tfvars
```

Update with your values. See [production README](2-environments/production/README.md) for details.

```bash
terraform -chdir=platform/2-environments/production init
terraform -chdir=platform/2-environments/production apply
```

**Verify prod environment:**
```bash
# Verify project
gcloud projects describe $(terraform -chdir=platform/2-environments/production output -raw prod_project_id)

# Verify APIs enabled
gcloud services list --project=$(terraform -chdir=platform/2-environments/production output -raw prod_project_id) --enabled
```

!!! warning "Stop if verification fails"
    Do not proceed if the prod project does not exist or required APIs are not enabled.
    Check terraform output for errors.

### 11. Configure CI Authentication

Generate service account keys:

```bash
# Get service account emails from 1-org outputs
PLATFORM_SA=$(terraform -chdir=platform/1-org output -raw platform_ci_service_account)
DEV_SA=$(terraform -chdir=platform/1-org output -raw dev_ci_service_account)
PROD_SA=$(terraform -chdir=platform/1-org output -raw prod_ci_service_account)

# Generate keys
gcloud iam service-accounts keys create platform-ci-key.json \
  --iam-account=$PLATFORM_SA

gcloud iam service-accounts keys create dev-ci-key.json \
  --iam-account=$DEV_SA

gcloud iam service-accounts keys create prod-ci-key.json \
  --iam-account=$PROD_SA
```

Store in GitHub organization secrets:

1. Navigate to `https://github.com/organizations/aincradot/settings/secrets/actions` (replace `aincradot` with your organization name)
2. Create `GCP_PLATFORM_SA_KEY` with contents of `platform-ci-key.json`
3. Create `GCP_SA_KEY` with contents of `dev-ci-key.json`
4. Create `GCP_SA_KEY_PROD` with contents of `prod-ci-key.json`

Delete local key files immediately:

```bash
rm *-ci-key.json
```

### 12. Deploy GitHub Organization Infrastructure (Optional)

!!! note
    This step is optional. For small teams (<10 people), manual GitHub management via UI may be more practical.
    Deploy this when you need reproducible GitHub org structure or as team grows.

Copy and edit the example file:

```bash
cp platform/3-github/example.terraform.tfvars platform/3-github/terraform.tfvars
```

Edit `terraform.tfvars` with:
- `shared_project_id` (from step 8 output)
- `github_organization` (your GitHub organization name)
- `teams` (your team members)
- `org_settings` (optional - exclude `billing_email`, manage billing manually via GitHub UI)

See [3-github README](3-github/README.md) for variable details.

```bash
terraform -chdir=platform/3-github init
terraform -chdir=platform/3-github apply
```

**Verify GitHub organization settings:**
- Check organization secrets exist: `https://github.com/organizations/aincradot/settings/secrets/actions`
- Verify teams created: `https://github.com/orgs/aincradot/teams`

!!! note
    GitHub App credentials are automatically read from Secret Manager (created in step 9). No manual PEM file configuration required.
