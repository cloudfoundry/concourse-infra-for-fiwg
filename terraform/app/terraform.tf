terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }

   backend "gcs" {
    bucket  = "terraform-state-wg-ci"
    prefix  = "terraform/state/app"
   }
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "gke_app-runtime-interfaces-wg_europe-west3-a_wg-ci"
}