# ============================================================================
# GCS Backend Configuration for 0-bootstrap
# ============================================================================
#
# INSTRUCTIONS FOR MIGRATING TO REMOTE STATE:
#
# After running your initial `terraform apply` with local backend:
#
# 1. Note the output value of `state_bucket_name` from the apply.
#
# 2. Update the `bucket` value below with your actual state bucket name.
#
# 3. Rename this file from `backend.gcs.example.tf` to `backend.gcs.tf`:
#
#    mv backend.gcs.example.tf backend.gcs.tf
#
# 4. Run the migration command:
#
#    terraform init -migrate-state
#
#    Terraform will detect the backend change and prompt you to migrate
#    your local state to the GCS bucket. Type 'yes' to confirm.
#
# 5. After successful migration, your local terraform.tfstate file is no
#    longer the source of truth. The state is now stored in GCS.
#
# ============================================================================

# terraform {
#   backend "gcs" {
#     bucket = "<STATE_BUCKET_NAME_FROM_0_BOOTSTRAP_OUTPUT>"
#     prefix = "terraform/bootstrap"
#   }
# }
