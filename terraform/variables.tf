variable "project" {
  type    = string
  default = "app-runtime-interfaces-wg"
}

variable "region" {
  type    = string
  default = "europe-west3"
}

variable "zone" {
  type    = string
  default = "europe-west3-a"
}

variable "dns_address" {
  type = map
  default = {
    name = "concourse-app-runtime-interfaces-ci-cloudfoundry-org"
    description = "https://concourse.app-runtime-interfaces.ci.cloudfoundry.org"
  }
}

variable "concourse_app" {
  type = map(any)
  default = {
    github_mainTeam = "sap-cloudfoundry:app-autoscaler"
  }
}

variable "kube" {
  type = map(any)
  default = {
    config  = "~/.kube/config"
    context = "gke_app-runtime-interfaces-wg_europe-west3-a_wg-ci"
  }
}