# Runbook: bootstrap GCP platform

This runbook describes the steps to run the GCP platform Terraform roots for the first time.

!!! note
    Each terraform root has its own README with detailed configuration options:
    
    - [platform/](../platform/README.md) - Overview and prerequisites
    - [0-bootstrap/](../platform/0-bootstrap/README.md) - Bootstrap project and state bucket
    - [1-org/](../platform/1-org/README.md) - Organizational folders and shared project
    - [2-environments/development/](../platform/2-environments/development/README.md) - Development environment
    - [2-environments/production/](../platform/2-environments/production/README.md) - Production environment

## Prerequisites

- GCP organisation exists.
- Billing account exists.
- You have an identity with organisation owner or equivalent permissions.
- Google Cloud SDK is installed on your machine.
- You have cloned the `platform` repository.

## Steps

1. Authenticate locally

```bash
gcloud auth application-default login
gcloud auth list
```

Confirm you are using the correct account.

2. Configure variables

Decide on the following values:

- organisation ID
- billing account ID
- bootstrap project ID
- Terraform state bucket name

Set them via a `terraform.tfvars` file in `platform/0-bootstrap`.

See `platform/0-bootstrap/variables.tf` for all available variables and their descriptions.

3. Run 0-bootstrap

```bash
cd platform/0-bootstrap
terraform init
terraform apply
```

This will create:

- Bootstrap project
- GCS bucket for Terraform state with versioning enabled
- Lifecycle rules to retain last 50 state versions

4. Run 1-org

```bash
cd ../1-org
terraform init
terraform apply
```

This will create:

- organisation level logging and security projects if configured
- folder structure for environments

5. Run 2-envs

```bash
cd ../2-environments/development
terraform init
terraform apply

cd ../production
terraform init
terraform apply
```

This will create development and production environment projects.

6. Verify

- Check that the state bucket exists and has versioning enabled
- Check that organizational folders (shared, dev, prod) exist
- Check that environment projects exist and are visible in the console
- Check that projects are attached to the central logging project's metrics scope

Record the project IDs and folder IDs - you'll need them for application repositories.
