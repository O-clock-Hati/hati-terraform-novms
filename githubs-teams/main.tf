# Add a collaborator to a repository

#data "github_user" "self" {
#  username = ""
#}
#
#data "github_organization" "hati" {
#  name = "O-clock-Hati"
#}
#
#output "users" {
#  value = data.github_organization.hati.users
#}

#resource "github_team" "la-meute" {
#  name = "la-meute"
#  description = "les meilleurs des devops"
#}
#
#resource "github_membership" "la-meute" {
#  username = "kuent1"
#  role     = "member"
#}

resource "github_repository_collaborator" "nous" {
  for_each = toset(var.users)
  repository = "o-clock-hati/hati-terraform-novms"
  username   = each.key
  permission = "admin"
}
