# Platform Terraform

GCP organization and environment infrastructure for Open Tibia services.

## What this creates

- Bootstrap project with GCS state bucket
- Organizational folders (shared, dev, prod)
- Development and production environment projects
- Central logging project with metrics scope

## Prerequisites

- GCP organization with billing account ([setup guide](../docs/requirements.md))
- `gcloud` CLI authenticated as org admin
- Terraform >= 1.5

## Directory structure

```
platform/
  0-bootstrap/     # Bootstrap project and state bucket
  1-org/           # Organizational folders and shared logging
  2-environments/
    development/   # Development environment project
    production/    # Production environment project
```

## Bootstrap procedure

Time: ~30 minutes total

### 1. Authenticate

```bash
gcloud auth application-default login
gcloud auth list  # Confirm correct account
```

### 2. Configure 0-bootstrap

Create `platform/0-bootstrap/terraform.tfvars`:

```hcl
org_id              = "123456789012"
billing_account_id  = "ABCDEF-123456-ABCDEF"
project_name        = "sao"
state_bucket_name   = "sao-tfstate"
location            = "europe-west3"
```

### 3. Run terraform

```bash
cd platform/0-bootstrap
terraform init
terraform apply

cd ../1-org
terraform init
terraform apply

cd ../2-environments/development
terraform init
terraform apply

cd ../production
terraform init
terraform apply
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

1. Running terraform from wrong directory
2. Not updating backend bucket names after bootstrap
3. Applying roots out of order (must be: 0-bootstrap, 1-org, 2-environments)
4. Missing folder_id from 1-org outputs in environment terraform.tfvars

### Recovery

If bootstrap fails completely:
1. Remove local state: `rm terraform.tfstate*`
2. Delete bootstrap project via console
3. Start over with `terraform init && terraform apply`
