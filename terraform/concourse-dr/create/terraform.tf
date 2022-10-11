terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}


provider "kubernetes" {
  config_path    = var.kube.config
  config_context = var.kube.context
}

