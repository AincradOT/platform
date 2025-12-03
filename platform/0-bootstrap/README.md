# 0-bootstrap

Purpose:

- Create the bootstrap project that will host Terraform state and shared platform tooling.
- Create the GCS bucket for Terraform remote state with versioning enabled.
- No real IDs or emails are committed; all inputs are variables.

Backend:

- This root intentionally uses the local backend. After applying, configure the remote state in subsequent roots using the created bucket name.

Inputs:

- `org_id`
- `billing_account_id`
- `bootstrap_project_id` (must be globally unique)
- `bootstrap_project_name` (optional)
- `state_bucket_name` (must be globally unique)
- `location` (GCS location, e.g. `US`, `EU`, `australia-southeast1`)

Outputs:

- `bootstrap_project_id`
- `state_bucket_name`

Apply order:

1) Run this stage first to create the state bucket.
2) Edit the commented `backends.tf` in `1-org` and `2-environments/*` to point at the created bucket.

Security:

- Do not store secrets or real identifiers in code.
- Optionally add CMEK for the state bucket later; left as a TODO here for simplicity.
