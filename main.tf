provider "tfe" {
  hostname = "app.terraform.io"
}

resource "tfe_workspace" "la_taniere" {
  name         = "la-taniere"
  organization = "hati-blue"
}
