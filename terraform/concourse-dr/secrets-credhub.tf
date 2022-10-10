# Saving credhub encryption key and config for DR purposes

data "kubernetes_secret_v1" "credhub_encryption_key" {
  metadata {
    name      = "credhub-encryption-key"
    namespace = "concourse"
  }

  binary_data = {
    password = ""
  }

}

resource "google_secret_manager_secret" "credhub_encryption_key" {
  secret_id = "${var.gke.name}-credhub-encryption-key"
  project = var.project

# when creating versions with gcloud it creates empty labels
  labels = {

  }
  replication {
    user_managed {
      replicas {
        location = "europe-west3"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "credhub_encryption_key" {
  secret = google_secret_manager_secret.credhub_encryption_key.id
  secret_data = base64decode(data.kubernetes_secret_v1.credhub_encryption_key.binary_data.password)

  lifecycle {
    # If omitted or unset terraform destroys previous versions which will make it impossible to
    # restore them. This is relevant in case of a desaster recovery where the
    # old secret version is needed to restore all credhub secrets.
    #
    # See: https://github.com/hashicorp/terraform-provider-google/issues/8653
    prevent_destroy = true
  }

}

# -------------------------------------------------------------------------------------------------------------------

data "kubernetes_secret_v1" "credhub_config" {
  metadata {
    name      = "credhub-config"
    namespace = "concourse"
  }

  binary_data = {
    "application.yml" = ""
  }
}

resource "google_secret_manager_secret" "credhub_config" {
  secret_id = "${var.gke.name}-credhub-config"
  project = var.project

# when creating versions with gcloud it creates empty labels
  labels = {

  }
  replication {
    user_managed {
      replicas {
        location = "europe-west3"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "credhub_config" {
  secret = google_secret_manager_secret.credhub_config.id
  secret_data = base64decode(data.kubernetes_secret_v1.credhub_config.binary_data["application.yml"])

  lifecycle {
    prevent_destroy = true
   }
}