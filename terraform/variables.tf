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

variable "gcs_state_bucket" {
  type = string
  default = "terraform-state-wg-ci"
}

variable "dns_address" {
  type = map
  default = {
    name = "concourse-app-runtime-interfaces-ci-cloudfoundry-org"
    description = "https://concourse.app-runtime-interfaces.ci.cloudfoundry.org"
  }
}

variable "db_instance" {
  type = string
  default = "concourse"
}
