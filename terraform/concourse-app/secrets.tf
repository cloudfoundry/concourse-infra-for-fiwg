resource "google_secret_manager_secret" "github_oauth" {
  secret_id = "${var.gke.name}-concourse-gitub-oauth"

  replication {
    user_managed {
      replicas {
        location = "europe-west3"
      }
    }
  }
}

data "google_secret_manager_secret_version" "github_oauth" {
  secret = google_secret_manager_secret.github_oauth.name
}

# resource "local_file" "concourse_secrets" {
#   content         = data.google_secret_manager_secret_version.github_oauth.secret_data
#   filename        = "/tmp/concourse-secrets.yml"
#   file_permission = "0600"
# }

resource "kubernetes_secret_v1" "github_oauth" {
  metadata {
    name = "github-test"
    namespace = "concourse"
  }

  data = {
    username = "admin"
    password = "P4ssw0rd"
  }
}