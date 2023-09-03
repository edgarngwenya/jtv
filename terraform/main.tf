terraform {
  required_version = "~> 1.2.0"

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "Cuvama-DEV"

    workspaces {
      prefix = "engineering-"
    }
  }
}
