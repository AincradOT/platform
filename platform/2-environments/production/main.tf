module "prod_environment" {
  source = "../../modules/environment-project"

  billing_account_id = var.billing_account_id
  folder_id          = local.folder_id
  shared_project_id  = local.shared_project_id
  project_id         = var.prod_project_id
  environment_name   = "production"

  project_display_name = var.prod_project_name
  ci_service_account   = local.prod_ci_service_account
  ci_storage_admin     = true

  iam_bindings = var.gcp_platform_viewers_group != null ? {
    platform_viewers = {
      role   = "roles/viewer"
      member = "group:${var.gcp_platform_viewers_group}"
    }
  } : {}

  labels = var.labels
}
