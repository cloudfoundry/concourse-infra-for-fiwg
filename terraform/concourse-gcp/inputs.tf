variable "project_id" {
  type = string
}

variable "gcp_credentials_json" {
  type = string
}

variable "name" {
  default = "bosh-concourse"
}

variable "internal_cidr" {
  default = "10.0.0.0/24"
}

variable "zone" {
  default = "europe-north2-a"
}

variable "region" {
  default = "europe-north2"
}
