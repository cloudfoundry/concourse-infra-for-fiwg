terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }

   backend "gcs" {
    bucket  = "terraform-state-wg-ci"
    prefix  = "terraform/state/wg-ci"
   }
}