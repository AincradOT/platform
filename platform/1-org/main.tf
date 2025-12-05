locals {
  labels = merge({
    environment = "platform",
    stage       = "foundation",
  }, var.labels)
}

# Top-level folders
resource "google_folder" "shared" {
  display_name = "shared"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "dev" {
  display_name = "dev"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "prod" {
  display_name = "prod"
  parent       = "organizations/${var.org_id}"
}

# Central logging/monitoring project (acts as metrics scope)
resource "google_project" "logging" {
  project_id      = var.logging_project_id
  name            = var.logging_project_name
  folder_id       = google_folder.shared.name
  billing_account = var.billing_account_id
  labels          = local.labels
}

resource "google_project_service" "logging_services" {
  for_each = toset([
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  project                    = google_project.logging.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Minimal org policy to avoid default VPC creation in new projects
resource "google_org_policy_policy" "skip_default_network" {
  name   = "organizations/${var.org_id}/policies/compute.skipDefaultNetworkCreation"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = true
    }
  }
}

# Optional viewer bindings for the logging project
resource "google_project_iam_member" "logging_viewers_logging" {
  count   = var.gcp_logging_viewers_group == null ? 0 : 1
  project = google_project.logging.project_id
  role    = "roles/logging.viewer"
  member  = "group:${var.gcp_logging_viewers_group}"
}

resource "google_project_iam_member" "logging_viewers_monitoring" {
  count   = var.gcp_logging_viewers_group == null ? 0 : 1
  project = google_project.logging.project_id
  role    = "roles/monitoring.viewer"
  member  = "group:${var.gcp_logging_viewers_group}"
}

# Optional minimal org-level IAM for admins (project creation)
resource "google_organization_iam_member" "org_project_creator" {
  count   = var.gcp_org_admins_group == null ? 0 : 1
  org_id  = var.org_id
  role    = "roles/resourcemanager.projectCreator"
  member  = "group:${var.gcp_org_admins_group}"
}

# Optional minimal billing admin on the billing account
resource "google_billing_account_iam_member" "billing_admin" {
  count               = var.gcp_billing_admins_group == null ? 0 : 1
  billing_account_id  = var.billing_account_id
  role                = "roles/billing.admin"
  member              = "group:${var.gcp_billing_admins_group}"
}
