# 2-environments: development

Purpose:

- Create a minimal development project for application teams to deploy into.
- Attach the project to the central metrics scope (logging project) for observability.
- Grant minimal IAM to a platform developers group.

Backend:

- Uses GCS remote backend configured in `backends.tf`.
- Update the `bucket` value with your state bucket name from `0-bootstrap` output.

Inputs (variables):

- `billing_account_id`
- `folder_id` (use the `dev_folder_id` output from `1-foundation`)
- `logging_project_id` (use the `logging_project_id` output from `1-foundation`)
- `dev_project_id` (unique, e.g. `sao-dev`)
- `dev_project_name` (default: `Development`)
- `gcp_platform_devs_group` (e.g. `platform-devs@example.com`)
- Optional: `labels`

Outputs:

- `dev_project_id`

Notes:

- IAM is intentionally minimal. For small teams, `roles/compute.instanceAdmin.v1` may be enough for VM-based stacks. You can add more roles as needed.
- No real emails or domains should be committed. Use groups you own in your domain.
