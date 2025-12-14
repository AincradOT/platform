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
    "cloudidentity.googleapis.com",
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

resource "google_org_policy_policy" "allow_sa_key_creation_in_shared_project" {
  name   = "projects/${google_project.shared.project_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "projects/${google_project.shared.project_id}"

  spec {
    rules {
      enforce = false
    }
  }
}

# Retrieve Cloud Identity customer ID for group creation
data "google_organization" "org" {
  organization = var.org_id
}

# Cloud Identity groups for human access
# These groups are created by terraform, membership is managed manually via Google Admin console
resource "google_cloud_identity_group" "logging_viewers" {
  display_name = "Logging Viewers"
  parent       = "customers/${data.google_organization.org.directory_customer_id}"

  group_key {
    id = "logging-viewers@${data.google_organization.org.domain}"
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}

resource "google_cloud_identity_group" "platform_admins" {
  display_name = "Platform Administrators"
  parent       = "customers/${data.google_organization.org.directory_customer_id}"

  group_key {
    id = "platform-admins@${data.google_organization.org.domain}"
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}

resource "google_cloud_identity_group" "billing_admins" {
  display_name = "Billing Administrators"
  parent       = "customers/${data.google_organization.org.directory_customer_id}"

  group_key {
    id = "billing-admins@${data.google_organization.org.domain}"
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}

# Human access via groups
# Logging viewers for troubleshooting and monitoring
resource "google_project_iam_member" "logging_viewers_logging" {
  project = google_project.shared.project_id
  role    = "roles/logging.viewer"
  member  = "group:${google_cloud_identity_group.logging_viewers.group_key[0].id}"
}

resource "google_project_iam_member" "logging_viewers_monitoring" {
  project = google_project.shared.project_id
  role    = "roles/monitoring.viewer"
  member  = "group:${google_cloud_identity_group.logging_viewers.group_key[0].id}"
}

# Platform admins for org-level project creation
resource "google_organization_iam_member" "org_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = "group:${google_cloud_identity_group.platform_admins.group_key[0].id}"
}

# Billing admins for cost management
resource "google_billing_account_iam_member" "billing_admin" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.admin"
  member             = "group:${google_cloud_identity_group.billing_admins.group_key[0].id}"
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

# Cloudflare Zone ID in Secret Manager (for application infrastructure modules)
resource "google_secret_manager_secret" "cloudflare_zone_id" {
  project   = google_project.shared.project_id
  secret_id = "cloudflare-zone-id"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "cloudflare_zone_id" {
  count       = var.cloudflare_zone_id != null && var.cloudflare_zone_id != "" ? 1 : 0
  secret      = google_secret_manager_secret.cloudflare_zone_id.id
  secret_data = var.cloudflare_zone_id

  lifecycle {
    ignore_changes = [secret_data]
  }
}

# Organisation-wide SOPS age private key for application/service repositories
resource "google_secret_manager_secret" "org_sops_age_key" {
  project   = google_project.shared.project_id
  secret_id = "org-sops-age-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "org_sops_age_key" {
  count       = var.org_sops_age_key != null && var.org_sops_age_key != "" ? 1 : 0
  secret      = google_secret_manager_secret.org_sops_age_key.id
  secret_data = var.org_sops_age_key

  lifecycle {
    ignore_changes = [secret_data]
  }
}

# SSH connection details for OVH VPS machines (development)
resource "google_secret_manager_secret" "dev_vps_ssh_host" {
  project   = google_project.shared.project_id
  secret_id = "dev-vps-ssh-host"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "dev_vps_ssh_host" {
  count       = var.dev_vps_ssh_host != null && var.dev_vps_ssh_host != "" ? 1 : 0
  secret      = google_secret_manager_secret.dev_vps_ssh_host.id
  secret_data = var.dev_vps_ssh_host

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "dev_vps_ssh_user" {
  project   = google_project.shared.project_id
  secret_id = "dev-vps-ssh-user"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "dev_vps_ssh_user" {
  count       = var.dev_vps_ssh_user != null && var.dev_vps_ssh_user != "" ? 1 : 0
  secret      = google_secret_manager_secret.dev_vps_ssh_user.id
  secret_data = var.dev_vps_ssh_user

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "dev_vps_ssh_password" {
  project   = google_project.shared.project_id
  secret_id = "dev-vps-ssh-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "dev_vps_ssh_password" {
  count       = var.dev_vps_ssh_password != null && var.dev_vps_ssh_password != "" ? 1 : 0
  secret      = google_secret_manager_secret.dev_vps_ssh_password.id
  secret_data = var.dev_vps_ssh_password

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "dev_vps_ssh_private_key" {
  project   = google_project.shared.project_id
  secret_id = "dev-vps-ssh-private-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "dev_vps_ssh_private_key" {
  count       = var.dev_vps_ssh_private_key != null && var.dev_vps_ssh_private_key != "" ? 1 : 0
  secret      = google_secret_manager_secret.dev_vps_ssh_private_key.id
  secret_data = var.dev_vps_ssh_private_key

  lifecycle {
    ignore_changes = [secret_data]
  }
}

# SSH connection details for OVH VPS machines (production)
resource "google_secret_manager_secret" "prod_vps_ssh_host" {
  project   = google_project.shared.project_id
  secret_id = "prod-vps-ssh-host"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "prod_vps_ssh_host" {
  count       = var.prod_vps_ssh_host != null && var.prod_vps_ssh_host != "" ? 1 : 0
  secret      = google_secret_manager_secret.prod_vps_ssh_host.id
  secret_data = var.prod_vps_ssh_host

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "prod_vps_ssh_user" {
  project   = google_project.shared.project_id
  secret_id = "prod-vps-ssh-user"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "prod_vps_ssh_user" {
  count       = var.prod_vps_ssh_user != null && var.prod_vps_ssh_user != "" ? 1 : 0
  secret      = google_secret_manager_secret.prod_vps_ssh_user.id
  secret_data = var.prod_vps_ssh_user

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "prod_vps_ssh_password" {
  project   = google_project.shared.project_id
  secret_id = "prod-vps-ssh-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "prod_vps_ssh_password" {
  count       = var.prod_vps_ssh_password != null && var.prod_vps_ssh_password != "" ? 1 : 0
  secret      = google_secret_manager_secret.prod_vps_ssh_password.id
  secret_data = var.prod_vps_ssh_password

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "prod_vps_ssh_private_key" {
  project   = google_project.shared.project_id
  secret_id = "prod-vps-ssh-private-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.shared_services]
}

resource "google_secret_manager_secret_version" "prod_vps_ssh_private_key" {
  count       = var.prod_vps_ssh_private_key != null && var.prod_vps_ssh_private_key != "" ? 1 : 0
  secret      = google_secret_manager_secret.prod_vps_ssh_private_key.id
  secret_data = var.prod_vps_ssh_private_key

  lifecycle {
    ignore_changes = [secret_data]
  }
}

# IAM bindings for Secret Manager secrets
# Cloudflare API token accessible by dev and prod CI service accounts
resource "google_secret_manager_secret_iam_member" "cloudflare_token_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.cloudflare_api_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudflare_token_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.cloudflare_api_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}

# Cloudflare Zone ID accessible by dev and prod CI service accounts
resource "google_secret_manager_secret_iam_member" "cloudflare_zone_id_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.cloudflare_zone_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudflare_zone_id_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.cloudflare_zone_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}

# SOPS age key accessible by dev/prod CI service accounts and platform admins
resource "google_secret_manager_secret_iam_member" "org_sops_age_key_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.org_sops_age_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "org_sops_age_key_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.org_sops_age_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "org_sops_age_key_platform_admins" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.org_sops_age_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "group:${google_cloud_identity_group.platform_admins.group_key[0].id}"
}

# GitHub App credentials accessible by platform CI service account only
resource "google_secret_manager_secret_iam_member" "github_app_id_platform_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.github_app_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.platform_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "github_app_installation_id_platform_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.github_app_installation_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.platform_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "github_app_private_key_platform_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.github_app_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.platform_ci.email}"
}

# Development VPS SSH credentials accessible by dev CI service account
resource "google_secret_manager_secret_iam_member" "dev_vps_ssh_host_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.dev_vps_ssh_host.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "dev_vps_ssh_user_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.dev_vps_ssh_user.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "dev_vps_ssh_password_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.dev_vps_ssh_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "dev_vps_ssh_private_key_dev_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.dev_vps_ssh_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dev_ci.email}"
}

# Production VPS SSH credentials accessible by prod CI service account
resource "google_secret_manager_secret_iam_member" "prod_vps_ssh_host_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.prod_vps_ssh_host.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "prod_vps_ssh_user_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.prod_vps_ssh_user.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "prod_vps_ssh_password_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.prod_vps_ssh_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}

resource "google_secret_manager_secret_iam_member" "prod_vps_ssh_private_key_prod_ci" {
  project   = google_project.shared.project_id
  secret_id = google_secret_manager_secret.prod_vps_ssh_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.prod_ci.email}"
}
