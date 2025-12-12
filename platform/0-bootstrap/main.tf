locals {
  bootstrap_project_id = "${var.project_name}-bootstrap"
  labels = merge({
    environment = "platform",
    stage       = "bootstrap",
  }, var.labels)
}

resource "google_project" "bootstrap" {
  project_id      = local.bootstrap_project_id
  name            = var.project_name
  org_id          = var.org_id
  billing_account = var.billing_account_id
  labels          = local.labels
}

resource "google_project_service" "enabled" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ])
  project                    = google_project.bootstrap.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
  depends_on                 = [google_project.bootstrap]
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  project                     = google_project.bootstrap.project_id
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 50
    }
  }
  lifecycle {
    prevent_destroy = true
  }
  labels     = local.labels
  depends_on = [google_project_service.enabled]
}
