# ============================================================================
# Terraform Backend Configuration (GCS)
# ============================================================================
#
# This root uses the GCS bucket created in 0-bootstrap for remote state.
#
# SETUP INSTRUCTIONS:
#
# 1. Complete the 0-bootstrap apply first to create the state bucket.
#
# 2. Update the `bucket` value below with the output from 0-bootstrap:
#
#    cd ../../0-bootstrap
#    terraform output state_bucket_name
#
# 3. Run terraform init in this directory:
#
#    cd ../2-environments/production
#    terraform init
#
# ============================================================================

terraform {
  backend "gcs" {
    bucket = "<STATE_BUCKET_NAME_FROM_0_BOOTSTRAP_OUTPUT>"
    prefix = "terraform/environments/production"
  }
}
