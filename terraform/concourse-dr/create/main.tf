# Saving credhub encryption key and config for DR purposes

data "kubernetes_secret_v1" "credhub_encryption_key" {
  metadata {
    name      = var.dr.credhub_encryption_key_name
    namespace = var.concourse_app.namespace
  }

  binary_data = {
    password = ""
  }

}

resource "google_secret_manager_secret" "credhub_encryption_key" {
  secret_id = "${var.gke.name}-${var.dr.credhub_encryption_key_name}"
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


resource "google_secret_manager_secret_version" "credhub_encryption_key" {
  secret      = google_secret_manager_secret.credhub_encryption_key.id
  secret_data = base64decode(data.kubernetes_secret_v1.credhub_encryption_key.binary_data.password)

  lifecycle {
    # If omitted or unset terraform destroys previous versions which will make it impossible to
    # restore them. This is relevant in case of a desaster recovery where the
    # history of secret might be needed to restore all credhub secrets.
    #
    # See: https://github.com/hashicorp/terraform-provider-google/issues/8653
    prevent_destroy = true

    # this secret will be created only once. to rotate it needs to be deleted via other means
    # with ignore all we work around credential deletions and build the history.
    # downside is terraform will be requesting update of metadata on each terraform apply (not an issue)
    ignore_changes = all
  }



}

# -------------------------------------------------------------------------------------------------------------------

data "kubernetes_secret_v1" "credhub_config" {
  metadata {
    name      = var.dr.credhub_config_name
    namespace = var.concourse_app.namespace
  }

  binary_data = {
    "application.yml" = ""
  }
}

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
  secret_data = base64decode(data.kubernetes_secret_v1.credhub_config.binary_data["application.yml"])

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}