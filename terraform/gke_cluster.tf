resource "google_container_cluster" "wg_ci" {
  name               = var.gke.name
  location           = var.zone
  project            = var.project
  min_master_version = var.gke.node_version
  initial_node_count = "1"
  remove_default_node_pool = true

  release_channel {
    channel = "STABLE"
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # init script uses --enable-autoscaling but in actual, it is disabled
  cluster_autoscaling {
    enabled = "false"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.gke.cluster_ipv4_cidr
    services_ipv4_cidr_block = var.gke.services_ipv4_cidr_block
  }
  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"

    master_global_access_config {
      enabled = "false"
    }

    master_ipv4_cidr_block = var.gke.master_ipv4_cidr_block
  }

  network            = google_compute_network.vpc.name
  subnetwork         = google_compute_subnetwork.default.name
  network_policy {
    enabled  = "false"
    provider = "PROVIDER_UNSPECIFIED"
  }

  networking_mode = "VPC_NATIVE"

 # other config
  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = "true"
    }

    horizontal_pod_autoscaling {
      disabled = "true"
    }

    http_load_balancing {
      disabled = "true"
    }

    network_policy_config {
      disabled = "true"
    }
  }

  database_encryption {
    state = "DECRYPTED"
  }

  default_max_pods_per_node = "110"

  default_snat_status {
    disabled = "true"
  }

  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  enable_intranode_visibility = "false"
  enable_kubernetes_alpha     = "false"
  enable_legacy_abac          = "false"
  enable_shielded_nodes       = "true"
  enable_tpu                  = "false"
  
  

  master_auth {
    client_certificate_config {
      issue_client_certificate = "false"
    }
  }


  service_external_ips_config {
    enabled = "true"
  }
  
  #googleapi: Error 400: Cannot specify logging_config or monitoring_config together with logging_service or monitoring_service., badRequest
  #logging_service = "logging.googleapis.com/kubernetes"
  #monitoring_service = "monitoring.googleapis.com/kubernetes"

}
