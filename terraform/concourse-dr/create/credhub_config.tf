resource "google_secret_manager_secret" "credhub_config" {
  secret_id = "${var.gke.name}-${var.dr.credhub_config_name}"
  project   = var.project

  # when creating versions with gcloud it creates empty labels
  labels = {

  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "credhub_config" {
  secret      = google_secret_manager_secret.credhub_config.id
  secret_data = base64decode(var.credhub_config.binary_data["application.yml"])

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

