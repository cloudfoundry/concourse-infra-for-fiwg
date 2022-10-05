resource "google_secret_manager_secret" "github_oauth" {
  secret_id = "${var.gke.name}-concourse-github-oauth"
  project = var.project
  replication {
    user_managed {
      replicas {
        location = "europe-west3"
      }
    }
  }
}
