# 1-foundation

Purpose:

- Create core organisation scaffolding.
- Create three top-level folders: `shared`, `dev`, `prod`.
- Create a central logging/monitoring project in the `shared` folder.
- Apply an org policy to prevent default VPC creation.
- Bind minimal viewer roles for observability to the logging project.

Backend:

- Uses GCS remote backend configured in `backends.tf`.
- Update the `bucket` value with your state bucket name from `0-bootstrap` output.

Inputs (variables):

- `org_id`
- `billing_account_id`
- `logging_project_id` (unique project id, e.g. `sao-shared-logging`)
- `logging_project_name` (default: `Shared Logging`)
- `gcp_logging_viewers_group` (e.g. `logging-viewers@example.com`)
- Optional: `labels`

Outputs:

- `shared_folder_id`
- `dev_folder_id`
- `prod_folder_id`
- `logging_project_id`

Notes:

- Group IAM is intentionally minimal here. Application/project-level IAM is handled in `2-environments/*`.
- If you need more restrictive policies, add additional `org-policy` constraints later.
- This stage intentionally does not create Google Groups to avoid domain coupling. Provide group emails via variables instead.
