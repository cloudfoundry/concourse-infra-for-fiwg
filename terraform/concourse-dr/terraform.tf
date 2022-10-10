terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }


  backend "gcs" {
    bucket = "terraform-state-wg-ci"
    prefix = "terraform/state/concourse-dr"
  }
}


provider "kubernetes" {
  config_path    = var.kube.config
  config_context = var.kube.context
}

data "terraform_remote_state" "concourse_app" {
  backend = "gcs"
  config = {
    bucket = "terraform-state-wg-ci"
    prefix = "terraform/state/concourse-app"

  }
}