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

output "shared_project_id" {
  description = "The shared services project id."
  value       = google_project.shared.project_id
}

output "platform_ci_service_account" {
  description = "Email of the platform CI service account."
  value       = google_service_account.platform_ci.email
}

output "dev_ci_service_account" {
  description = "Email of the development CI service account."
  value       = google_service_account.dev_ci.email
}

output "prod_ci_service_account" {
  description = "Email of the production CI service account."
  value       = google_service_account.prod_ci.email
}
