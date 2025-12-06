# Platform Terraform

GCP organization and environment infrastructure for Open Tibia services.

## What this creates

- Bootstrap project with GCS state bucket
- Organizational folders (shared, dev, prod)
- Development and production environment projects
- Central logging project with metrics scope

## Prerequisites

- GCP organization with billing account ([setup guide](../requirements.md))
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
project_name        = "yourorg"
state_bucket_name   = "yourorg-tfstate"
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
