# GitHub Module Implementation TODO

## Technical Requirements

- [ ] GitHub provider ~> 6.0 with terraform >= 1.5
- [ ] GCS backend using shared state bucket with prefix `terraform/github`
- [ ] GitHub token from environment variable or Secret Manager (never committed)
- [ ] Drift tolerance design - terraform bootstraps structure but doesn't enforce on every apply

## Design Requirements

- [ ] Organization settings resource (2FA required, base permissions: read)
- [ ] Teams: platform, game, web, readers with descriptions
- [ ] Core repositories: platform, game-infra, game-server, web-ui (ensure exist)
- [ ] Branch protection: main and prod branches (require PRs, status checks, no force push)
- [ ] Standard labels: infra, ops, bug, enhancement, security
- [ ] Repository team permissions (platform team = maintain on platform repo, etc.)

## Implementation Notes

- Use `lifecycle { prevent_destroy = true }` on critical resources
- Ignore changes to team memberships (manual management acceptable)
- Document that repository creation outside terraform is allowed
- Token rotation strategy: manual rotation every 6 months
