
variable "gke" {
  type = map
  default = {
    name = "wg-ci"
    controlplane_version = "1.23.8-gke.1900"
    cluster_ipv4_cidr = "10.104.0.0/14"
    services_ipv4_cidr_block = "10.108.0.0/20"
    master_ipv4_cidr_block = "172.16.0.32/28"
  }
}