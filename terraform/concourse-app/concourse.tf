# resource "concourse_team" "my_team" {
#   team_name = "my-team"

#   owners = [
#     "group:github:org-name",
#     "group:github:org-name:team-name",
#     "user:github:tlwr",
#   ]

#   viewers = [
#     "user:github:samrees"
#   ]
# }

data "concourse_teams" "teams" {
}

output "team_names" {
  value = data.concourse_teams.teams.names
}