# ====================================================================
# GitHub Teams Management Configuration
# This module handles the creation and management of GitHub teams
# including team creation, member assignments, and maintainer roles.
# Teams are used to organize users and control access to repositories
# with appropriate permission levels and privacy settings.
# ====================================================================

# Create teams based on configuration
resource "github_team" "teams" {
  for_each = var.teams

  name        = each.key
  description = each.value.description
  privacy     = each.value.privacy

  lifecycle {
    ignore_changes = [
      name,
      description,
      privacy
    ]
  }
}

# Assign team members with member role
resource "github_team_membership" "members" {
  for_each = merge([
    for team_name, team_config in var.teams : {
      for member in team_config.members : "${team_name}-${member}" => {
        team_id  = github_team.teams[team_name].id
        username = member
        role     = "member"
      }
    }
  ]...)

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role

  lifecycle {
    ignore_changes = [
      username,
      role
    ]
  }
}

# Assign team maintainers with maintainer role
resource "github_team_membership" "maintainers" {
  for_each = merge([
    for team_name, team_config in var.teams : {
      for maintainer in coalesce(team_config.maintainers, []) : "${team_name}-${maintainer}" => {
        team_id  = github_team.teams[team_name].id
        username = maintainer
        role     = "maintainer"
      }
    }
  ]...)

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role

  lifecycle {
    ignore_changes = [
      username,
      role
    ]
  }
}
