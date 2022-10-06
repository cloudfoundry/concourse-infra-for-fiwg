data "concourse_teams" "teams" {
}

output "team_names" {
  value = data.concourse_teams.teams.names
}