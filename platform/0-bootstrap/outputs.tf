output "bootstrap_project_id" {
  description = "The bootstrap project ID."
  value       = google_project.bootstrap.project_id
}

output "state_bucket_name" {
  description = "The name of the GCS bucket used for Terraform state."
  value       = google_storage_bucket.tf_state.name
}
