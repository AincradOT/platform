# github

GitHub organization structure, teams, repositories, and branch protections.

## What this creates

- Organization settings (2FA required, base permission: read)
- Core teams: platform, game, web, readers with repository permissions
- Core repositories: platform, game-infra, game-server, web-ui (ensures they exist)
- Branch protection rules for main and prod branches
- Standard labels: infra, ops, bug, enhancement, security

**Drift tolerance:** Terraform bootstraps the structure but does not revert manual changes via GitHub UI. This allows operational flexibility while maintaining infrastructure as code for reproducibility.

## Configuration

Update `backends.tf` with your state bucket from `0-bootstrap` output.

Create `terraform.tfvars`:

```hcl
github_org_name = "aincradot"
```

**GitHub token:** Supplied via environment variable `GITHUB_TOKEN`, never committed to repository.

## Variables

| Name | Description | Required |
|------|-------------|----------|
| `github_org_name` | GitHub organization name | Yes |
| `github_token` | GitHub token (from environment variable) | Yes |
| `core_repositories` | Core repositories to manage | No (default: ["platform", "game-infra", "game-server", "web-ui"]) |
| `require_2fa` | Require 2FA for all members | No (default: true) |
| `default_repository_permission` | Base permission for members | No (default: "read") |

## Outputs

- `organization_name` - GitHub organization name
- `team_ids` - Map of team names to team IDs
- `repository_names` - List of managed repository names

## Notes

- **Drift tolerance:** Manual changes via GitHub UI are not reverted by terraform
- **Team memberships:** Can be managed manually at first, or codified later if needed
- **Repository creation:** Non-core repositories can be created manually as needed
- **Branch protection:** Requires pull requests, status checks, disallows force pushes
- **Token rotation:** Rotate GitHub token every 6 months
- **Organization settings:** 2FA required, base permission is read (not write/admin)
- **Goal:** Codify critical structure and guardrails, not micromanage everything

### Team Permissions

- `platform` team: maintain rights on `platform` repo, read on everything else
- `game` team: write/maintain rights on `game-infra` and `game-server`
- `web` team: write/maintain rights on `web-ui`
- `readers` team: read-only access for visibility without write access

### When to Use

For teams < 10 people, manual GitHub management via UI may be more practical than terraform. Implement when:
- Team grows beyond 5-10 developers
- Manual management becomes operational overhead
- Need for drift detection and reproducible organization structure

---

## Implementation Status

**Not yet implemented.** See `TODO.md` for technical and design requirements.
