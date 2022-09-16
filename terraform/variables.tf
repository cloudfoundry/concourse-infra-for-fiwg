variable "project" {
  type = string
  default = "app-runtime-interfaces-wg"
}

variable "region" {
  type = string
  default = "europe-west3"
}

variable "zone" {
  type = string
  default = "europe-west3-a"
}

variable "gcs-terrafom-state-bucket" {
  type = string
  default = "terraform-state-wg-ci"
}