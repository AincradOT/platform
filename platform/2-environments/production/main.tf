module "prod_environment" {
  source = "../../modules/environment-project"

  billing_account_id = var.billing_account_id
  folder_id          = var.folder_id
  shared_project_id  = var.shared_project_id
  project_id         = var.prod_project_id
  environment_name   = "production"

  project_display_name = var.prod_project_name
  ci_service_account   = var.prod_ci_service_account

  iam_bindings = var.gcp_platform_viewers_group != null ? {
    platform_viewers = {
      role   = "roles/viewer"
      member = "group:${var.gcp_platform_viewers_group}"
    }
  } : {}

  labels = var.labels
}
