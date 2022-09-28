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

variable "gke" {
  type = map
  default = {
    name = "wg-ci"
    controlplane_version = "1.23.8-gke.1900"
    cluster_ipv4_cidr = "10.104.0.0/14"
    services_ipv4_cidr_block = "10.108.0.0/20"
    master_ipv4_cidr_block = "172.16.0.32/28"
    machine_type = "n1-standard-4"
  }
}

