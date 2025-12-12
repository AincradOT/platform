# ====================================================================
# Top Level Output Values
# This file aggregates outputs from all modules to provide a
# comprehensive view of the created GitHub infrastructure including
# organization details, teams, repositories, and security configurations.
# Outputs are organized by domain for easy reference.
# ====================================================================

output "organization" {
  description = "Organization configuration and details"
  value = {
    name = var.github_organization
    url  = "https://github.com/${var.github_organization}"
    # settings = module.organization.organization_settings  # Temporarily disabled
  }
}
