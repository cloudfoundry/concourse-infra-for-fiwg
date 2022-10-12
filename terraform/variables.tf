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
  type = map(any)
  default = {
    name        = "concourse-app-runtime-interfaces-ci-cloudfoundry-org"
    description = "https://concourse.app-runtime-interfaces.ci.cloudfoundry.org"
  }
}

variable "gke" {
  type = map(any)
  default = {
    name                      = "wg-ci"
    controlplane_version      = "1.23.8-gke.1900"
    cluster_ipv4_cidr         = "10.104.0.0/14"
    services_ipv4_cidr_block  = "10.108.0.0/20"
    master_ipv4_cidr_block    = "172.16.0.32/28"
    machine_type_default_pool = "e2-standard-4"
    machine_type_workers_pool = "n2-standard-4"
  }
}

variable "concourse_app" {
  type = map(string)
  default = {
    kapp_app   = "concourse-app"
    namespace  = "concourse"
    fly_target = "app-runtime-interfaces"
    # Use \\ to escape comma separated entries - helm-chart-provider interpration
    github_mainTeam     = "cloudfoundry:wg-app-runtime-interfaces-autoscaler-approvers"
    github_mainTeamUser = ""
  }
}

variable "kube" {
  type = map(any)
  default = {
    config  = "~/.kube/config"
    # TODO: try to provide context dynamically by reading GKE
    context = "gke_app-runtime-interfaces-wg_europe-west3-a_wg-ci"
  }
}

variable "sql_instance_name" {
  type    = string
  default = "concourse"
}

variable "sql_database" {
  type    = list(any)
  default = ["concourse", "uaa", "credhub"]
}


