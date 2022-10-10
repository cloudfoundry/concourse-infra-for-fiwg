resource "google_compute_address" "concourse_app" {
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
  name         = var.dns_address["name"]
  description  = var.dns_address["description"]
}

resource "google_dns_managed_zone" "dns" {
  name        = "app-runtime-interfaces"
  dns_name    = "app-runtime-interfaces.ci.cloudfoundry.org."
  description = "app-runtime-interfaces WG DNS zone"
  project     = var.project
  visibility  = "public"
}


resource "google_dns_record_set" "concourse" {
  managed_zone = google_dns_managed_zone.dns.name
  name         = "concourse.${google_dns_managed_zone.dns.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_address.concourse_app.address]
  ttl          = 300
  project      = var.project
}
