output "load_balancer_ip" {
  value = google_compute_address.concourse_app.address
}