# Remote state data sources to avoid manual output copying
# This pulls folder IDs, project IDs, and service account emails from 1-org outputs

data "terraform_remote_state" "org" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket_name
    prefix = "terraform/org"
  }
}

locals {
  # Pull from remote state, but allow override via variable for initial bootstrap
  folder_id               = var.folder_id != null ? var.folder_id : data.terraform_remote_state.org.outputs.prod_folder_id
  shared_project_id       = var.shared_project_id != null ? var.shared_project_id : data.terraform_remote_state.org.outputs.shared_project_id
  prod_ci_service_account = var.prod_ci_service_account != null ? var.prod_ci_service_account : data.terraform_remote_state.org.outputs.prod_ci_service_account
}
