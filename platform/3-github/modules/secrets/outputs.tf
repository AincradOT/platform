output "secrets" {
  description = "Created GitHub organization secrets"
  value = {
    renovate_token     = github_actions_organization_secret.renovate_token.secret_name
    ghcr_token_private = github_actions_organization_secret.ghcr_token_private.secret_name
    pages_token        = github_actions_organization_secret.pages_token.secret_name
  }
}
