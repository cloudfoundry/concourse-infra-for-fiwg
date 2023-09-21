output "jumpbox_ip" {
  value = google_compute_address.jumpbox.address
}

output "zone" {
  value = var.zone
}

output "network" {
  value = var.name
}

output "subnetwork" {
  value = google_compute_subnetwork.bosh-subnet.name
}

output "project_id" {
  value = var.project_id
}

output "internal_cidr" {
  value = var.internal_cidr
}

output "internal_gw" {
  value = cidrhost(var.internal_cidr, 1)
}

output "internal_jumpbox_ip" {
  value = cidrhost(var.internal_cidr, 2)
}

output "internal_director_ip" {
  value = cidrhost(var.internal_cidr, 3)
}

output "concourse_web_target_pool" {
  value = google_compute_target_pool.concourse_web_target_pool.name
}
