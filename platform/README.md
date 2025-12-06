# Platform Terraform

GCP organization and environment infrastructure for Open Tibia services.

## What this creates

- Bootstrap project with GCS state bucket
- Organizational folders (shared, dev, prod)
- Shared services project (logging, monitoring, service accounts, secrets)
- Development and production environment projects

**Directory structure:**

```
platform/
  0-bootstrap/     # Bootstrap project and state bucket
  1-org/           # Organizational folders and shared services
  2-environments/
    development/   # Development environment project
    production/    # Production environment project
```

## Prerequisites

- GCP organization with billing account ([setup guide](/docs/requirements.md))
- `gcloud` CLI authenticated as org admin
- Terraform >= 1.6.0

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

### 3. Run terraform

```bash
cd platform/0-bootstrap
terraform init
terraform apply
```

**Verify bootstrap:**
```bash
# Confirm project exists
gcloud projects describe $(terraform output -raw bootstrap_project_id)

# Confirm bucket exists with versioning
gsutil versioning get gs://$(terraform output -raw state_bucket_name)
```

### 4. Configure 1-org

Copy and edit the example file:

```bash
cp platform/1-org/example.terraform.tfvars platform/1-org/terraform.tfvars
```

Update with your values. The `state_bucket_name` should match the output from 0-bootstrap. See [1-org README](1-org/README.md) for all available variables.

### 5. Run terraform

```bash
cd ../1-org
terraform init
terraform apply
```

**Verify org structure:**
```bash
# List folders (replace 123456789012 with your org ID)
gcloud resource-manager folders list --organization=123456789012

# Verify shared services project
gcloud projects describe $(terraform output -raw shared_project_id)
```

### 6. Configure and deploy environments

Copy and edit example files:

```bash
cp platform/2-environments/development/example.terraform.tfvars platform/2-environments/development/terraform.tfvars
```

Update with your values. Only `billing_account_id`, `state_bucket_name`, and `dev_project_id` are required. Values like `folder_id` and `shared_project_id` are **automatically pulled from 1-org remote state**. See [development README](2-environments/development/README.md) for details.

```bash
cd ../2-environments/development
terraform init
terraform apply
```

**Verify dev environment:**
```bash
# Verify project
gcloud projects describe $(terraform output -raw dev_project_id)

# Verify APIs enabled
gcloud services list --project=$(terraform output -raw dev_project_id) --enabled
```

```bash
cp platform/2-environments/production/example.terraform.tfvars platform/2-environments/production/terraform.tfvars
```

Update with your values. See [production README](2-environments/production/README.md) for details.

```bash
cd ../production
terraform init
terraform apply
```

**Verify prod environment:**
```bash
# Verify project
gcloud projects describe $(terraform output -raw prod_project_id)

# Verify APIs enabled
gcloud services list --project=$(terraform output -raw prod_project_id) --enabled
```

### 7. Configure CI Authentication

Generate service account keys:

```bash
# Get service account emails from 1-org outputs
cd platform/1-org
PLATFORM_SA=$(terraform output -raw platform_ci_service_account)
DEV_SA=$(terraform output -raw dev_ci_service_account)
PROD_SA=$(terraform output -raw prod_ci_service_account)

# Generate keys (run from repository root)
cd ../..
gcloud iam service-accounts keys create platform-ci-key.json \
  --iam-account=$PLATFORM_SA

gcloud iam service-accounts keys create dev-ci-key.json \
  --iam-account=$DEV_SA

gcloud iam service-accounts keys create prod-ci-key.json \
  --iam-account=$PROD_SA
```

Store in GitHub organization secrets:

1. Navigate to `https://github.com/organizations/<your-org>/settings/secrets/actions` (replace `<your-org>` with your organization name)
2. Create `GCP_PLATFORM_SA_KEY` with contents of `platform-ci-key.json`
3. Create `GCP_SA_KEY` with contents of `dev-ci-key.json`
4. Create `GCP_SA_KEY_PROD` with contents of `prod-ci-key.json`

Delete local key files immediately:

```bash
rm *-ci-key.json
```

**Set calendar reminder for quarterly key rotation (90 days).**

## State management

- `0-bootstrap` uses local backend initially
- After bootstrap, migrate to GCS backend
- `1-org` and `2-environments` use GCS backend with separate prefixes

See each terraform root's README for detailed configuration.

## Troubleshooting

### Authentication issues

Error: `Error getting access token` or `status code 403`

Verify your account has necessary permissions:
- Check active account: `gcloud auth list`
- Verify org access: `gcloud organizations list`
- Required org-level roles: `organizationAdmin`, `projectCreator`, `billing.admin`

### State bucket errors

Error: `backend initialization required`

Backend configuration changed. Get correct bucket name from bootstrap output and update all backends.tf files:
```bash
cd platform/0-bootstrap
terraform output state_bucket_name
```

Error: `bucket already exists`

Bucket name must be globally unique. Change `state_bucket_name` in terraform.tfvars.

### Project creation failures

Error: `project ID is not available`

Project ID already exists or recently deleted. Wait 30 days or choose different ID.

Error: `billing not enabled`

Verify billing account access: `gcloud billing accounts list`

### Common mistakes

1. Running terraform from wrong directory
2. Not updating backend bucket names after bootstrap
3. Applying roots out of order (must be: 0-bootstrap, 1-org, 2-environments)
4. Missing folder_id from 1-org outputs in environment terraform.tfvars

### Recovery

#### Complete bootstrap failure

If bootstrap fails after project creation but before bucket is created:

```bash
# Delete the project
gcloud projects delete PROJECT_ID --quiet

# Wait for deletion to complete (30 seconds)
sleep 30

# Remove local state
cd platform/0-bootstrap
rm -f terraform.tfstate*

# Start over
terraform init
terraform apply
```

#### Project ID already exists

Error: `project ID is not available`

Project was recently deleted (30-day retention period).

Options:
1. Wait 30 days for permanent deletion
2. Restore the deleted project:
   ```bash
   gcloud projects undelete PROJECT_ID
   ```
3. Choose a different project_name in terraform.tfvars

#### Bucket already exists

Error: `bucket already exists`

Bucket names are globally unique. If someone else owns this name:

```bash
# Try a different name
state_bucket_name = "sao-tfstate-abc123"  # Add random suffix
```

#### Partial state corruption

If terraform.tfstate exists but resources are out of sync:

```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Try refreshing state
terraform refresh

# If that fails, reimport resources
terraform import google_project.bootstrap PROJECT_ID
terraform import google_storage_bucket.tf_state BUCKET_NAME
```
