# ============================================================================
# Backend Configuration for 0-bootstrap
# ============================================================================
#
# INITIAL SETUP: Uses local backend (implicit)
# Terraform state is stored in local terraform.tfstate file
#
# AFTER FIRST APPLY: Migrate to GCS backend
#
# 1. Run initial apply (uses local state):
#    terraform init && terraform apply
#
# 2. Note the output: state_bucket_name
#
# 3. Uncomment/replace the backend block below
#
# 4. Migrate state to GCS:
#    terraform init -migrate-state
#    (Type 'yes' when prompted)
#
# 5. Local terraform.tfstate is no longer used - state is now in GCS
#
# ============================================================================

terraform {
  backend "gcs" {
    bucket = "aincrad-tfstate"
    prefix = "terraform/bootstrap"
  }
}
