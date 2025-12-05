output "shared_folder_id" {
  description = "Folder ID for shared services."
  value       = google_folder.shared.name
}

output "dev_folder_id" {
  description = "Folder ID for dev workloads."
  value       = google_folder.dev.name
}

output "prod_folder_id" {
  description = "Folder ID for prod workloads."
  value       = google_folder.prod.name
}

output "logging_project_id" {
  description = "The central logging/monitoring project id."
  value       = google_project.logging.project_id
}
