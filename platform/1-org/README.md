# 1-org

Purpose:

- Create core organisation scaffolding for a small team.
- Create three top-level folders: `Platform`, `Development`, `Production`.
- Create a central logging/monitoring project to act as the metrics scope.
- Apply a minimal org policy to prevent default VPC creation.
- Bind minimal viewer roles for observability to the logging project.

Backend:

- Uses a GCS remote backend. Provide your bucket/prefix via a local `backend.hcl` file (gitignored).
- Example `backend.hcl.example` is provided; copy to `backend.hcl` and set values locally.

Inputs (variables):

- `org_id`
- `billing_account_id`
- `logging_project_id` (unique project id, e.g. `platform-logging`)
- `logging_project_name` (default: `Platform Logging`)
- `gcp_logging_viewers_group` (e.g. `logging-viewers@example.com`)
- Optional: `labels`

Outputs:

- `platform_folder_id`
- `development_folder_id`
- `production_folder_id`
- `logging_project_id`

Notes:

- Group IAM is intentionally minimal here. Application/project-level IAM is handled in `2-environments/*`.
- If you need more restrictive policies, add additional `org-policy` constraints later.
- This stage intentionally does not create Google Groups to avoid domain coupling. Provide group emails via variables instead.
