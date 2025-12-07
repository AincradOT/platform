output "teams" {
  description = "Created teams and their details"
  value = {
    for team_name, team in github_team.teams : team_name => {
      id          = team.id
      slug        = team.slug
      name        = team.name
      description = team.description
      url         = "https://github.com/orgs/${var.github_organization}/teams/${team.slug}"
    }
  }
}

output "team_ids" {
  description = "Map of team names to team IDs for use in other modules"
  value = {
    for team_name, team in github_team.teams : team_name => team.id
  }
}
