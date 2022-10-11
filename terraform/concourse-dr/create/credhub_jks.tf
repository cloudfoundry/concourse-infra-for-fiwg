resource "google_secret_manager_secret" "credhub_keystore_key" {
  secret_id = "${var.gke.name}-${var.dr.credhub_keystore_key_name}"
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

resource "google_secret_manager_secret_version" "credhub_keystore_key" {
  secret      = google_secret_manager_secret.credhub_keystore_key.id
  secret_data = base64decode(var.credhub_keystore_key.binary_data.password)

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

# -------------------

resource "google_secret_manager_secret" "credhub_truststore_key" {
  secret_id = "${var.gke.name}-${var.dr.credhub_truststore_key_name}"
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

resource "google_secret_manager_secret_version" "credhub_truststore_key" {
  secret      = google_secret_manager_secret.credhub_truststore_key.id
  secret_data = base64decode(var.credhub_truststore_key.binary_data.password)

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}