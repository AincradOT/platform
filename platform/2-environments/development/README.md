# 2-environments: development

Purpose:

- Create a minimal development project for application teams to deploy into.
- Attach the project to the central metrics scope (logging project) for observability.
- Grant minimal IAM to a platform developers group.

Backend:

- Uses a GCS remote backend. Provide your bucket/prefix via a local `backend.hcl` file (gitignored).
- Example `backend.hcl.example` is provided; copy to `backend.hcl` and set values locally.

Inputs (variables):

- `billing_account_id`
- `folder_id` (use the `development_folder_id` output from `1-org`)
- `logging_project_id` (use the `logging_project_id` output from `1-org`)
- `dev_project_id` (unique, e.g. `platform-dev`)
- `dev_project_name` (default provided)
- `gcp_platform_devs_group` (e.g. `platform-devs@example.com`)
- Optional: `labels`

Outputs:

- `dev_project_id`

Notes:

- IAM is intentionally minimal. For small teams, `roles/compute.instanceAdmin.v1` may be enough for VM-based stacks. You can add more roles as needed.
- No real emails or domains should be committed. Use groups you own in your domain.
