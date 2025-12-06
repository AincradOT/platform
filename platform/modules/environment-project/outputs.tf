output "project_id" {
  description = "The environment project ID."
  value       = google_project.env.project_id
}

output "project_number" {
  description = "The environment project number."
  value       = google_project.env.number
}
