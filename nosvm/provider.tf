provider "aws" {
  region = "eu-west-3"
}
provider "dns" {
}
provider "tfe" {
  hostname = "app.terraform.io"
}