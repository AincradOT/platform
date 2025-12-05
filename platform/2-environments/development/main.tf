locals {
  labels = merge({
    environment = "development",
    stage       = "env",
  }, var.labels)
}

# Development project
resource "google_project" "dev" {
  project_id      = var.dev_project_id
  name            = var.dev_project_name
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  labels          = local.labels
}

# Minimal set of common APIs for a VM-based or simple app stack
resource "google_project_service" "enabled" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  project                    = google_project.dev.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Attach development project to central metrics scope (logging project)
resource "google_monitoring_monitored_project" "dev" {
  metrics_scope = "locations/global/metricsScopes/${var.logging_project_id}"
  name          = google_project.dev.project_id
}

# Minimal IAM for platform developers in development
resource "google_project_iam_member" "platform_devs_compute_admin" {
  count   = var.gcp_platform_devs_group == null ? 0 : 1
  project = google_project.dev.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "group:${var.gcp_platform_devs_group}"
}
