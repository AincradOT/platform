# Terraform backend (GCS)
# If you pre-create the state bucket on day 0, provide configuration via backend.hcl (gitignored)
terraform {
  backend "gcs" {}
}
