## Grant CI access to manage backup buckets

Use this when application Terraform needs to create or manage its own backup bucket and the environment CI service account lacks `storage.buckets.create`.

### Preconditions
- Target project ID (dev or prod environment project).
- Environment CI service account email (from `platform/1-org` output, e.g. `dev-ci@<shared-project>.iam.gserviceaccount.com`).
- Application repo already uses the environment CI credentials (see `docs/architecture/ci.md`).

### Recommended role
- Use project-scoped `roles/storage.admin` so Terraform can create, update, and destroy the bucket plus configure lifecycle/UBLA.
- Keep scope to the specific environment project. Do **not** grant org/folder scope.

### Terraform snippet (in the application repo)
Grant the environment CI SA bucket admin in the target project:

```hcl
variable "project_id" {
  type = string
}

variable "ci_service_account" {
  type = string
}

resource "google_project_iam_member" "ci_bucket_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${var.ci_service_account}"
}
```

- Set `project_id` to the dev/prod project you deploy into.
- Set `ci_service_account` to `dev-ci@<shared-project>.iam.gserviceaccount.com` or `prod-ci@<shared-project>.iam.gserviceaccount.com`.
- Run `terraform plan`/`apply` in the application repo. The CI workflow will then be able to create the bucket.

### After the bucket exists
- If Terraform will continue to manage bucket settings (versioning, lifecycle, UBLA), keep `roles/storage.admin`.
- If future applies only manage objects, you may replace the project role with a bucket-scoped binding:
  - `roles/storage.objectAdmin` on the bucket for writes.
  - Keep `roles/storage.legacyBucketReader` off (UBLA already enabled by Terraform).

### Verification
- `gcloud projects get-iam-policy <project_id> --flatten=bindings --filter="bindings.members:dev-ci@..."` (optional check).
- Re-run the failing Terraform apply; bucket creation should succeed.
