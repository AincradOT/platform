locals {
  labels = merge({
    environment = "production",
    stage       = "env",
  }, var.labels)
}

# Production project
resource "google_project" "prod" {
  project_id      = var.prod_project_id
  name            = var.prod_project_name
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  labels          = local.labels
}

# Minimal set of common APIs
resource "google_project_service" "enabled" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  project                    = google_project.prod.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Attach production project to central metrics scope (logging project)
resource "google_monitoring_monitored_project" "prod" {
  metrics_scope = "locations/global/metricsScopes/${var.logging_project_id}"
  name          = google_project.prod.project_id
}

# Minimal viewer permissions in production
resource "google_project_iam_member" "platform_viewers_viewer" {
  count   = var.gcp_platform_viewers_group == null ? 0 : 1
  project = google_project.prod.project_id
  role    = "roles/viewer"
  member  = "group:${var.gcp_platform_viewers_group}"
}

# Grant prod CI service account editor role on prod project
resource "google_project_iam_member" "prod_ci_editor" {
  count   = var.prod_ci_service_account != null ? 1 : 0
  project = google_project.prod.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${var.prod_ci_service_account}"
}
