# 2-environments: production

Purpose:

- Create a minimal production project for application teams to deploy into.
- Attach the project to the central metrics scope (logging project) for observability.
- Grant only viewer-level access by default to a platform viewers group (tighten or expand as needed).

Backend:

- Uses GCS remote backend configured in `backends.tf`.
- Update the `bucket` value with your state bucket name from `0-bootstrap` output.

Inputs (variables):

- `billing_account_id`
- `folder_id` (use the `prod_folder_id` output from `1-foundation`)
- `logging_project_id` (use the `logging_project_id` output from `1-foundation`)
- `prod_project_id` (unique, e.g. `sao-prod`)
- `prod_project_name` (default: `Production`)
- `gcp_platform_viewers_group` (e.g. `platform-viewers@example.com`)
- Optional: `labels`

Outputs:

- `prod_project_id`

Notes:

- Keep IAM tighter in production. Start with viewer and explicitly add permissions your ops model needs.
- No real emails or domains should be committed. Use groups you own in your domain.
