terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  credentials = var.gcp_credentials_json
  region      = var.region
}

resource "google_compute_network" "network" {
  name                    = var.name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "bosh-subnet" {
  name          = "${var.name}-bosh-subnet"
  ip_cidr_range = var.internal_cidr
  network       = google_compute_network.network.name
  region        = var.region
}

resource "google_compute_subnetwork" "integration-subnet" {
  count         = 4
  name          = "bosh-integration-${count.index}"
  ip_cidr_range = "10.100.${count.index}.0/24"
  network       = google_compute_network.network.name
  region        = var.region
}

resource "google_compute_firewall" "inter-subnet" {
  count   = 4
  name    = "bosh-integration-${count.index}-access"
  network = google_compute_network.network.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.100.${count.index}.0/24"]
}

resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  region  = google_compute_subnetwork.bosh-subnet.region
  network = google_compute_network.network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_address" "jumpbox" {
  name   = "${var.name}-jumpbox-ip"
  region = var.region
}

resource "google_compute_firewall" "mbus-jumpbox" {
  name    = "${var.name}-jumpbox-ingress"
  network = google_compute_network.network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6868"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jumpbox"]
}

resource "google_compute_firewall" "director-ingress" {
  name    = "${var.name}-director-from-jumpbox"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "5985", "5986", "6868", "8443", "8844", "25555"]
  }

  source_tags = ["jumpbox"]
  target_tags = ["bosh-deployed"]
}

resource "google_compute_firewall" "bosh-internal" {
  name    = "${var.name}-bosh-internal"
  network = google_compute_network.network.name

  allow {
    protocol = "all"
  }

  source_tags = ["bosh-deployed", "test-stemcells-bats", "test-stemcells-ipv4"]
  target_tags = ["bosh-deployed", "test-stemcells-bats", "test-stemcells-ipv4"]
}

resource "google_compute_address" "concourse_lb" {
  name   = "${var.name}-concourse-web-ip"
  region = var.region
}

resource "google_compute_firewall" "concourse-web-ingress" {
  name    = "${var.name}-concourse-web-from-internet"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = [
      "443",
      "2222"
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["concourse"]
}

// Load balancer
// We health check credhub rather than concourse since concourse has no dedicated health endpoint
// and starts reporting 200 as soon as it starts even though it takes a couple minutes for uaa and then credhub to start
resource "google_compute_http_health_check" "concourse_credhub_health_check" {
  name                = "${var.name}-credhub-health-check"
  healthy_threshold   = 2
  unhealthy_threshold = 1
  port                = 8845
  request_path        = "/health"
}

resource "google_compute_target_pool" "concourse_web_target_pool" {
  name          = "${var.name}-web"
  health_checks = [
    google_compute_http_health_check.concourse_credhub_health_check.name
  ]
}

resource "google_compute_forwarding_rule" "concourse_forwarding_rule_http" {
  name       = "${var.name}-forwarding-rule-http"
  target     = google_compute_target_pool.concourse_web_target_pool.self_link
  port_range = "80-80"
  ip_address = google_compute_address.concourse_lb.address
}

resource "google_compute_forwarding_rule" "concourse_forwarding_rule_https" {
  name       = "${var.name}-forwarding-rule-https"
  target     = google_compute_target_pool.concourse_web_target_pool.self_link
  port_range = "443-443"
  ip_address = google_compute_address.concourse_lb.address
}

resource "google_compute_forwarding_rule" "concourse_forwarding_rule_worker" {
  name       = "${var.name}-forwarding-rule-worker"
  target     = google_compute_target_pool.concourse_web_target_pool.self_link
  port_range = "2222-2222"
  ip_address = google_compute_address.concourse_lb.address
}
