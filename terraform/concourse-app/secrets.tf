# Provide github oauth token prior to app deployment
data "google_secret_manager_secret_version" "github_oauth" {
  secret = data.terraform_remote_state.infra.outputs.github_oauth.name
}

locals {
  github_oauth = yamldecode(data.google_secret_manager_secret_version.github_oauth.secret_data)
}

resource "kubernetes_secret_v1" "github_oauth" {
  metadata {
    name      = "github"
    namespace = var.concourse_app.namespace
  }
  data = {
    id     = local.github_oauth["id"]
    secret = local.github_oauth["secret"]
  }
}


# Save encryption key once app is deployed
data "kubernetes_secret_v1" "credhub_encryption_key" {
  metadata {
    name      = "credhub-encryption-key"
    namespace = var.concourse_app.namespace
  }
  binary_data = {
    password = ""
  }
  depends_on = [carvel_kapp.concourse_app]
}

resource "google_secret_manager_secret" "credhub_encryption_key" {
  secret_id = "${var.gke.name}-credhub-encryption-key"
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
    # no further changes will be applied 
    # if the encryption key will change it will not be updated on secret manager
    ignore_changes = all

  }
  depends_on = [carvel_kapp.concourse_app]
}

