resource "google_compute_address" "concourse_app-runtime-interfaces_ci" {
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
  name         = var.dns_address["name"]
  description =  var.dns_address["description"]
}