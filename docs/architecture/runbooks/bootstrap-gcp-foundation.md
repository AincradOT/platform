# Runbook: bootstrap GCP foundation

This runbook describes the steps to run the GCP foundation Terraform roots for the first time.

## Prerequisites

- GCP organisation exists.
- Billing account exists.
- You have an identity with organisation owner or equivalent permissions.
- Google Cloud SDK is installed on your machine.
- You have cloned the `foundation` repository.

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
- bootstrap project ID prefix
- names for the Terraform state bucket and KMS key

Set them via a `terraform.tfvars` file or environment variables in `cloud/0-bootstrap`.

3. Run 0-bootstrap

```bash
cd cloud/0-bootstrap
terraform init
terraform apply
```

This will create:

- a bootstrap project
- a GCS bucket for Terraform state
- a KMS key for encryption
- initial service accounts

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
cd ../2-envs
terraform init
terraform apply
```

This will create environment projects such as `env-dev` and `env-prod`.

6. Verify

- Check that the state bucket exists and has versioning enabled.
- Check that environment projects exist and are visible in the console.
- Check that service accounts have been created as expected.

Record the IDs of the environment projects for use in application repositories.
