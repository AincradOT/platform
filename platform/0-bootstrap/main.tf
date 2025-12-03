locals {
  labels = merge({
    environment = "platform",
    stage       = "bootstrap",
  }, var.labels)

  # Effective project IDs whether the project is created here or pre-created via CLI
  bootstrap_project_id = var.bootstrap_project_id
  bucket_project_id    = var.state_bucket_project_id != "" ? var.state_bucket_project_id : var.bootstrap_project_id
}

# Bootstrap project to host state and shared tooling
resource "google_project" "bootstrap" {
  count           = var.create_bootstrap_project ? 1 : 0
  project_id      = var.bootstrap_project_id
  name            = var.bootstrap_project_name
  org_id          = var.org_id
  billing_account = var.billing_account_id
  labels          = local.labels
}

# Minimal set of APIs for state and org operations
resource "google_project_service" "enabled" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ])
  project                    = local.bootstrap_project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Remote state bucket (optional if pre-created via CLI)
resource "google_storage_bucket" "tf_state" {
  count                       = var.create_state_bucket ? 1 : 0
  name                        = var.state_bucket_name
  project                     = local.bucket_project_id
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
  labels = local.labels
}

# TODO: Optionally add CMEK (KMS) for bucket encryption
