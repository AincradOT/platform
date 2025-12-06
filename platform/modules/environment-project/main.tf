locals {
  labels = merge({
    environment = var.environment_name,
    stage       = "env",
  }, var.labels)
}

# Environment project
resource "google_project" "env" {
  project_id      = var.project_id
  name            = var.project_display_name != "" ? var.project_display_name : var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  labels          = local.labels
}

# Common APIs for environment projects
resource "google_project_service" "enabled" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  project                    = google_project.env.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Attach project to central metrics scope
resource "google_monitoring_monitored_project" "env" {
  metrics_scope = "locations/global/metricsScopes/${var.logging_project_id}"
  name          = google_project.env.project_id
}

# Optional IAM bindings
resource "google_project_iam_member" "ci_editor" {
  count   = var.ci_service_account != null ? 1 : 0
  project = google_project.env.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${var.ci_service_account}"
}

resource "google_project_iam_member" "custom_iam" {
  for_each = var.iam_bindings
  project  = google_project.env.project_id
  role     = each.value.role
  member   = each.value.member
}
