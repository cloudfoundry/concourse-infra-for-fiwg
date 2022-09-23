terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }

   backend "gcs" {
    bucket  = "terraform-state-wg-ci"
    prefix  = "terraform/state/infra"
   }
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
