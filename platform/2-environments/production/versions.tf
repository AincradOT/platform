terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }
}

# Get bootstrap project from remote state to use as quota project
data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket_name
    prefix = "terraform/bootstrap"
  }
}

locals {
  bootstrap_project_id = data.terraform_remote_state.bootstrap.outputs.bootstrap_project_id
}

provider "google" {
  billing_project       = local.bootstrap_project_id
  user_project_override = true
}

provider "google-beta" {
  billing_project       = local.bootstrap_project_id
  user_project_override = true
}
