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

**Before starting the bootstrap, complete the manual setup:**
- GCP organization with billing account
- GitHub organization
- Domain and DNS in Cloudflare
- Organization-level IAM roles granted to your account

See the complete [Manual Setup Guide](https://aincradot.github.io/platform/requirements/) for step-by-step instructions.

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

Edit `platform/0-bootstrap/backends.tf` and uncomment/replace the `terraform` block with GCS backend. Update the `bucket` name:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-state-bucket-name"  # From step 3 output
    prefix = "terraform/bootstrap"
  }
}
```

Migrate state:

```bash
terraform -chdir=platform/0-bootstrap init -migrate-state
```

Type `yes` when prompted. If migration fails, see [0-bootstrap README](0-bootstrap/README.md) for troubleshooting.

### 6. Configure 1-org

Copy and edit the example file:

```bash
cp platform/1-org/example.terraform.tfvars platform/1-org/terraform.tfvars
```

Update with your values. The `state_bucket_name` should match the output from 0-bootstrap. See [1-org README](1-org/README.md) for all available variables.

### 7. Enable required APIs

**Why:** The Organization Policy API is required to manage organization policies (such as skipping default network creation).

Enable the API in the bootstrap project:

```bash
gcloud services enable orgpolicy.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable cloudresourcemanager.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable cloudbilling.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable iam.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
gcloud services enable servicenetworking.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
```

!!! note
    The API may take a few seconds to propagate after enabling.
    If you encounter API-related errors during the next step, wait 30 seconds and try again.

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
```

!!! warning "Stop if verification fails"
    Do not proceed if folders are not created or the shared services project does not exist.
    Review terraform output for errors and re-run `terraform apply` if needed.

### 9. Store API credentials in Secret Manager

!!! note "Single source of truth"
    API credentials (GitHub App, Cloudflare) are stored in GCP Secret Manager.
    Platform and application modules will read from Secret Manager to manage infrastructure.

Add the credentials to `platform/1-org/terraform.tfvars` using the values you noted during [manual setup](https://aincradot.github.io/platform/requirements):

```hcl
# GitHub App credentials (use values from manual setup)
github_app_id              = "123456"  # Your App ID
github_app_installation_id = "12345678"  # Your Installation ID
github_app_private_key     = <<-EOT
-----BEGIN RSA PRIVATE KEY-----
[paste contents of your .pem file]
-----END RSA PRIVATE KEY-----
EOT

# Cloudflare API token
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
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

**Clean up:**

After the initial sync:

1. Remove the API credentials from your `terraform.tfvars` file:
   ```hcl
   # Remove these lines after initial sync
   # github_app_id              = "123456"
   # github_app_installation_id = "12345678"
   # github_app_private_key     = <<-EOT ...
   # cloudflare_api_token       = "..."
   ```

2. Delete the local PEM file:
   ```bash
   rm ~/Downloads/platform-automation.*.private-key.pem
   ```

Secret Manager is now the single source of truth. The `lifecycle { ignore_changes }` policy ensures terraform won't try to update them on subsequent applies.

- The `3-github` module will read from Secret Manager and create GitHub organization secrets automatically
- The `4-cloudflare` module and application modules will read the Cloudflare token from Secret Manager

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

1. Navigate to `https://github.com/organizations/yourorg/settings/secrets/actions` (replace `yourorg` with your organization name)
2. Create `GCP_PLATFORM_SA_KEY` with contents of `platform-ci-key.json`
3. Create `GCP_SA_KEY` with contents of `dev-ci-key.json`
4. Create `GCP_SA_KEY_PROD` with contents of `prod-ci-key.json`

Delete local key files immediately:

```bash
rm *-ci-key.json
```

## State management

- `0-bootstrap` uses local backend initially
- After bootstrap, migrate to GCS backend
- `1-org` and `2-environments` use GCS backend with separate prefixes

See each terraform root's README for detailed configuration.
