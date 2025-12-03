# 2-environments: production

Purpose:

- Create a minimal production project for application teams to deploy into.
- Attach the project to the central metrics scope (logging project) for observability.
- Grant only viewer-level access by default to a platform viewers group (tighten or expand as needed).

Backend:

- Uses a GCS remote backend. Provide your bucket/prefix via a local `backend.hcl` file (gitignored).
- Example `backend.hcl.example` is provided; copy to `backend.hcl` and set values locally.

Inputs (variables):

- `billing_account_id`
- `folder_id` (use the `production_folder_id` output from `1-org`)
- `logging_project_id` (use the `logging_project_id` output from `1-org`)
- `prod_project_id` (unique, e.g. `foundations-prod`)
- `prod_project_name` (default provided)
- `gcp_platform_viewers_group` (e.g. `platform-viewers@example.com`)
- Optional: `labels`

Outputs:

- `prod_project_id`

Notes:

- Keep IAM tighter in production. Start with viewer and explicitly add permissions your ops model needs.
- No real emails or domains should be committed. Use groups you own in your domain.
