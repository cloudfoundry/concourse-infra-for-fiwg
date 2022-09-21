resource "google_container_cluster" "wg_ci" {
  name               = "wg-ci"
  release_channel {
    channel = "STABLE"
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }
  region = var.region

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

  cluster_ipv4_cidr = "10.104.0.0/14"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.104.0.0/14"
    services_ipv4_cidr_block = "10.108.0.0/20"
  }
  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"

    master_global_access_config {
      enabled = "false"
    }

    master_ipv4_cidr_block = "172.16.0.32/28"
  }




 ###### old stuff
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  network            = "projects/cloud-foundry-310819/global/networks/default"

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

  enable_binary_authorization = "false"
  enable_intranode_visibility = "false"
  enable_kubernetes_alpha     = "false"
  enable_legacy_abac          = "false"
  enable_shielded_nodes       = "true"
  enable_tpu                  = "false"
  initial_node_count          = "0"



  location = "europe-west4-a"


  logging_service = "logging.googleapis.com/kubernetes"

  master_auth {
    client_certificate_config {
      issue_client_certificate = "false"
    }
  }




  network_policy {
    enabled  = "false"
    provider = "PROVIDER_UNSPECIFIED"
  }

  networking_mode = "VPC_NATIVE"
  node_version    = "1.22.12-gke.500"



  project = "cloud-foundry-310819"

  service_external_ips_config {
    enabled = "true"
  }

  subnetwork = "projects/cloud-foundry-310819/regions/europe-west4/subnetworks/default"

}
