# Platform Teardown

Complete decommissioning of the platform infrastructure to stop all billing and remove resources.

## Prerequisites

- `gcloud` CLI authenticated as org admin
- `terraform` installed
- Access to GitHub organization settings
- Cloudflare account access

## Cost Warning

After teardown, you will no longer incur charges for:
- GCP projects and resources (~$1-3/month)
- GitHub Team plan ($12/month if applicable)
- Cloudflare domain renewal ($~10/year)

## Teardown Order

### 1. Destroy Environment Projects

```bash
cd platform/2-environments/production
terraform destroy
# Type 'yes' when prompted

cd ../development
terraform destroy
# Type 'yes' when prompted
```

### 2. Destroy Organization Resources

```bash
cd ../../1-org
terraform destroy
# Type 'yes' when prompted
```

This removes:
- Organizational folders
- Shared services project
- CI service accounts

### 3. Destroy Bootstrap Resources

```bash
cd ../0-bootstrap
terraform destroy
# Type 'yes' when prompted
```

This removes:
- Bootstrap project
- Terraform state bucket (versioned objects will be deleted)

### 4. Manual Cleanup

#### GCP Organization

Projects are soft-deleted with 30-day retention. To immediately free up project IDs:

```bash
# List deleted projects
gcloud projects list --filter="lifecycleState:DELETE_REQUESTED"

# Permanently delete (skips 30-day retention)
gcloud projects delete PROJECT_ID --quiet
```

To completely remove the GCP organization:
1. Navigate to [IAM Admin Settings](https://console.cloud.google.com/iam-admin/settings)
2. Delete the organization (requires no active projects)

#### GitHub Organization

1. Navigate to organization settings: `https://github.com/organizations/<your-org>/settings` (replace `<your-org>` with your organization name)
2. Scroll to "Danger Zone"
3. Click "Delete this organization"
4. Confirm by typing the organization name

**Warning:** This deletes all repositories, issues, PRs, and team history. Export any data you need first.

#### Cloudflare

1. Log in to Cloudflare dashboard
2. Remove DNS records pointing to decommissioned infrastructure
3. To cancel domain:
   - Navigate to domain → Overview → Domain Registration
   - Disable auto-renewal
   - Domain will expire at end of registration period

## Verification

After teardown, confirm no resources remain:

```bash
# Check for any active projects (replace <org-id> with your organization ID)
gcloud projects list --organization=<org-id>

# List all projects to verify none remain
gcloud projects list
```

## Billing

- GCP charges stop within 24 hours of resource deletion
- GitHub billing stops at end of current billing period
- Cloudflare domain renewal stops after disabling auto-renewal

## Recovery

If you destroyed resources by mistake:

- **GCP projects**: Restorable for 30 days via `gcloud projects undelete PROJECT_ID`
- **State bucket**: Check versioning history if recently deleted
- **GitHub org**: Not recoverable - permanent deletion
- **Terraform state**: Keep local backups of `terraform.tfstate` files before running destroy
