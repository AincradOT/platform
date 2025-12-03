output "platform_folder_id" {
  description = "Folder resource name for Platform."
  value       = google_folder.platform.name
}

output "development_folder_id" {
  description = "Folder resource name for Development."
  value       = google_folder.development.name
}

output "production_folder_id" {
  description = "Folder resource name for Production."
  value       = google_folder.production.name
}

output "logging_project_id" {
  description = "The central logging/monitoring project id."
  value       = google_project.logging.project_id
}
