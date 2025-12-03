output "bootstrap_project_id" {
  description = "The bootstrap project ID."
  value       = var.bootstrap_project_id
}

output "state_bucket_name" {
  description = "The name of the GCS bucket used for Terraform state."
  value       = var.state_bucket_name
}
