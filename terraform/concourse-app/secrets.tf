data "google_secret_manager_secret_version" "github_oauth" {
  secret = data.terraform_remote_state.infra.outputs.github_oauth.name
}

locals {
  github_oauth = yamldecode(data.google_secret_manager_secret_version.github_oauth.secret_data)
}

resource "kubernetes_secret_v1" "github_oauth" {
  metadata {
    name      = "github"
    namespace = "concourse"
  }

  data = {
    id     = local.github_oauth["id"]
    secret = local.github_oauth["secret"]
  }
}

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