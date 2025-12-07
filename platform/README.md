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

**Why:** Application Default Credentials need a quota project for API calls.

Set the bootstrap project as the quota project:

```bash
gcloud auth application-default set-quota-project $(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
```

This prevents "quota project not set" errors when terraform makes API calls.

### 5. Migrate bootstrap state to GCS

**Why:** The bootstrap state is initially stored locally. Migrate it to GCS for consistency.

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

Type `yes` when prompted. If migration fails, see [0-bootstrap README](0-bootstrap/README.md#migrate-to-remote-state) for troubleshooting.

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
gcloud services enable cloudkms.googleapis.com --project=$(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)
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

### 9. Configure and deploy environments

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

### 9. Configure CI Authentication

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

1. Not having organization-level IAM permissions before starting
2. Not setting quota project after bootstrap
3. Running terraform from wrong directory
4. Not updating backend bucket names after bootstrap
5. Applying roots out of order (must be: 0-bootstrap, 1-org, 2-environments)
6. Missing folder_id from 1-org outputs in environment terraform.tfvars
7. Not migrating bootstrap state before running 1-org
8. Forgetting to authenticate with `gcloud auth application-default login`

### Permission denied errors

**Error**: `Permission 'resourcemanager.folders.create' denied`

**Cause**: Account lacks organization-level permissions

**Fix**:
```bash
# Get your organization ID
gcloud organizations list

# Have an org admin grant you Organization Admin role
ORG_ID="your-org-id"
USER_EMAIL=$(gcloud config get-value account)

gcloud organizations add-iam-policy-binding $ORG_ID \
  --member="user:$USER_EMAIL" \
  --role="roles/resourcemanager.organizationAdmin"

# Wait 2 minutes for IAM propagation
sleep 120
terraform -chdir=platform/1-org apply
```

**Error**: `API requires a quota project, which is not set by default`

**Cause**: Application Default Credentials don't have a quota project configured

**Fix**:
```bash
# Set bootstrap project as quota project
gcloud auth application-default set-quota-project $(terraform -chdir=platform/0-bootstrap output -raw bootstrap_project_id)

# Retry the failed terraform command
terraform -chdir=platform/1-org apply
```

### Remote state data source errors

**Error**: `Error reading remote state: bucket not found`

**Cause**: 1-org or 2-environments trying to read from non-existent state bucket

**Fix**:
```bash
# Verify bootstrap state bucket exists
gsutil ls gs://your-state-bucket-name/terraform/bootstrap/

# Verify 1-org state exists
gsutil ls gs://your-state-bucket-name/terraform/org/

# Check backends.tf has correct bucket name in all roots
grep -r "bucket =" platform/*/backends.tf
```

### Service account key upload errors

**Error**: GitHub Actions fails with "invalid service account key"

**Cause**: Key file corrupted during copy/paste or has extra whitespace

**Fix**:
```bash
# Verify key is valid JSON
cat platform-ci-key.json | jq .

# Use file upload in GitHub UI instead of copy/paste
# Or use GitHub CLI:
gh secret set GCP_PLATFORM_SA_KEY < platform-ci-key.json
```

### Organization policy conflicts

**Error**: `Constraint constraints/compute.skipDefaultNetworkCreation conflicts`

**Cause**: Existing org policy preventing default VPC creation

**Fix**:
```bash
# List existing org policies
gcloud org-policies list --organization=123456789012

# If conflicting policy exists, terraform will override it
# No manual action needed unless policy is enforced at folder level
```

### IAM permission propagation delays

**Error**: `Permission denied` immediately after granting IAM role

**Cause**: IAM changes can take up to 2 minutes to propagate

**Fix**:
```bash
# Wait 2 minutes and retry
sleep 120
terraform apply
```

### Quota exceeded errors

**Error**: `Quota 'PROJECTS' exceeded`

**Cause**: Organization has project creation quota limit

**Fix**:
```bash
# Request quota increase via console:
# https://console.cloud.google.com/iam-admin/quotas

# Or clean up deleted projects (they count toward quota for 30 days)
gcloud projects list --filter="lifecycleState:DELETE_REQUESTED"
gcloud projects delete PROJECT_ID --quiet  # Permanent deletion
```

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

Wait 30 days for permanent deletion, or restore the deleted project:
```bash
gcloud projects undelete PROJECT_ID
```

Or choose a different project_name in terraform.tfvars.

#### Bucket already exists

Error: `bucket already exists`

Bucket names are globally unique. If someone else owns this name:

```bash
# Try a different name
state_bucket_name = "aincrad-tfstate-abc123"  # Add random suffix
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
