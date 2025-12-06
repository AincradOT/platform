# CI Service Accounts for GitHub Actions
# These service accounts are used by CI pipelines to run terraform and manage infrastructure
# Service accounts are created in the shared logging project

# Platform CI service account - manages org-level resources and platform infrastructure
resource "google_service_account" "platform_ci" {
  project      = google_project.logging.project_id
  account_id   = "platform-ci"
  display_name = "Platform CI Service Account"
  description  = "Service account for GitHub Actions to manage platform infrastructure (org, folders, projects)"
}

# Development CI service account - manages dev environment infrastructure
resource "google_service_account" "dev_ci" {
  project      = google_project.logging.project_id
  account_id   = "dev-ci"
  display_name = "Development CI Service Account"
  description  = "Service account for GitHub Actions to manage development environment infrastructure"
}

# Production CI service account - manages prod environment infrastructure
resource "google_service_account" "prod_ci" {
  project      = google_project.logging.project_id
  account_id   = "prod-ci"
  display_name = "Production CI Service Account"
  description  = "Service account for GitHub Actions to manage production environment infrastructure"
}

# Grant platform CI access to manage org-level resources
resource "google_organization_iam_member" "platform_ci_folder_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${google_service_account.platform_ci.email}"
}

resource "google_organization_iam_member" "platform_ci_project_creator" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${google_service_account.platform_ci.email}"
}

resource "google_organization_iam_member" "platform_ci_org_viewer" {
  org_id = var.org_id
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.platform_ci.email}"
}

# Grant all CI service accounts access to state bucket
# Note: State bucket name must be provided as a variable since it's created in 0-bootstrap
resource "google_storage_bucket_iam_member" "platform_ci_state_admin" {
  count  = var.state_bucket_name != null ? 1 : 0
  bucket = var.state_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.platform_ci.email}"
}

resource "google_storage_bucket_iam_member" "dev_ci_state_admin" {
  count  = var.state_bucket_name != null ? 1 : 0
  bucket = var.state_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_storage_bucket_iam_member" "prod_ci_state_admin" {
  count  = var.state_bucket_name != null ? 1 : 0
  bucket = var.state_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.prod_ci.email}"
}

# Grant dev/prod CI accounts billing user role to create resources in their projects
resource "google_billing_account_iam_member" "dev_ci_billing_user" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_billing_account_iam_member" "prod_ci_billing_user" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.prod_ci.email}"
}

# Note: Project-level IAM for dev/prod CI accounts must be added in 2-environments/*/
# to avoid circular dependencies between terraform roots
