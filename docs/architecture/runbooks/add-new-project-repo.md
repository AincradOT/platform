# Runbook: adding a new project repository

This runbook covers how to add a new application or service repository that consumes the existing platform foundations.

## Prerequisites

- GCP environment projects exist and are recorded.
- GitHub foundation is already applied.
- You know which team owns the new project.

## Steps

1. Create the repository

- In GitHub create a new repository under the organisation.
- Choose visibility (private or public).
- Add initial code, including a `README.md`.

If the repository should be treated as core infrastructure, add it to the `github/` Terraform configuration later so it is managed as code.

2. Set up Terraform backend

In the new repository, configure the backend to use the shared GCS bucket:

```hcl
terraform {
  backend "gcs" {
    bucket = "tf-state-platform-001"
    prefix = "new-service/dev"
  }
}
```

Use a separate prefix per environment and per Terraform root.

3. Reference environment projects

Add variables for the environment project IDs and pass them into the root module. These IDs come from the GCP foundation.

4. Configure CI authentication

- Add secrets or variables for `GCP_WIF_PROVIDER` and `GCP_CI_SERVICE_ACCOUNT`.
- Create a GitHub Actions workflow that:
  - requests an OIDC token
  - uses the `google-github-actions/auth` action
  - runs `terraform plan` and `terraform apply` as needed

Ensure the Workload Identity binding for this repository has been created in the platform `cloud/` root.

5. Add team permissions

- Add the owning team to the repository with the correct permission level.
- If the repository is core, also add it to `github/` Terraform configuration so team permissions are enforced by code.

6. Verify

- Run `terraform init` and `terraform plan` locally.
- Trigger the CI workflow and ensure it can authenticate to GCP and reach the correct project.
- Confirm branch protection and team access behave as expected.
