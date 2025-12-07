locals {
  labels = merge({
    environment = "platform",
    stage       = "org",
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

# Shared services project (logging, monitoring, service accounts, secrets)
resource "google_project" "shared" {
  project_id      = var.shared_project_id
  name            = var.shared_project_name
  folder_id       = google_folder.shared.name
  billing_account = var.billing_account_id
  labels          = local.labels
}

resource "google_project_service" "shared_services" {
  for_each = toset([
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  project                    = google_project.shared.project_id
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

# Optional viewer bindings for the shared services project
resource "google_project_iam_member" "logging_viewers_logging" {
  count   = var.gcp_logging_viewers_group == null ? 0 : 1
  project = google_project.shared.project_id
  role    = "roles/logging.viewer"
  member  = "group:${var.gcp_logging_viewers_group}"
}

resource "google_project_iam_member" "logging_viewers_monitoring" {
  count   = var.gcp_logging_viewers_group == null ? 0 : 1
  project = google_project.shared.project_id
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

# GitHub App credentials in Secret Manager (mirrors GitHub org secrets for local dev)
# These are synced once during initial bootstrap, then managed via lifecycle ignore_changes
resource "google_secret_manager_secret" "github_app_id" {
  project   = google_project.shared.project_id
  secret_id = "github-app-id"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "github_app_id" {
  count       = var.github_app_id != null && var.github_app_id != "" ? 1 : 0
  secret      = google_secret_manager_secret.github_app_id.id
  secret_data = var.github_app_id

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "github_app_installation_id" {
  project   = google_project.shared.project_id
  secret_id = "github-app-installation-id"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "github_app_installation_id" {
  count       = var.github_app_installation_id != null && var.github_app_installation_id != "" ? 1 : 0
  secret      = google_secret_manager_secret.github_app_installation_id.id
  secret_data = var.github_app_installation_id

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "github_app_private_key" {
  project   = google_project.shared.project_id
  secret_id = "github-app-private-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "github_app_private_key" {
  count       = var.github_app_private_key != null && var.github_app_private_key != "" ? 1 : 0
  secret      = google_secret_manager_secret.github_app_private_key.id
  secret_data = var.github_app_private_key

  lifecycle {
    ignore_changes = [secret_data]
  }
}

# Cloudflare API token in Secret Manager (for application infrastructure modules)
resource "google_secret_manager_secret" "cloudflare_api_token" {
  project   = google_project.shared.project_id
  secret_id = "cloudflare-api-token"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "cloudflare_api_token" {
  count       = var.cloudflare_api_token != null && var.cloudflare_api_token != "" ? 1 : 0
  secret      = google_secret_manager_secret.cloudflare_api_token.id
  secret_data = var.cloudflare_api_token

  lifecycle {
    ignore_changes = [secret_data]
  }
}
