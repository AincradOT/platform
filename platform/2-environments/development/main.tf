module "dev_environment" {
  source = "../../modules/environment-project"

  billing_account_id = var.billing_account_id
  folder_id          = local.folder_id
  shared_project_id  = local.shared_project_id
  project_id         = var.dev_project_id
  environment_name   = "development"

  project_display_name = var.dev_project_name
  ci_service_account   = local.dev_ci_service_account

  iam_bindings = var.gcp_platform_devs_group != null ? {
    platform_devs = {
      role   = "roles/compute.instanceAdmin.v1"
      member = "group:${var.gcp_platform_devs_group}"
    }
  } : {}

  labels = var.labels
}
