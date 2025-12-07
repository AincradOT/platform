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
