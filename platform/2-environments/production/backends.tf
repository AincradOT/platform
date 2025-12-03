# Terraform backend (GCS)
# Configuration (bucket, prefix) is provided via a local backend.hcl file (gitignored)
terraform {
  backend "gcs" {}
}
