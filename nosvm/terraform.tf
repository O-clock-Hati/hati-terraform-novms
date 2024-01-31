terraform {
  cloud {
    organization = "hati-chou"

    workspaces {
      name = "kame-house"
    }
  }
}