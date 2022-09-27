resource "google_service_account" "cloud-sql-auth-proxy" {
  account_id    = "cloud-sql-auth-proxy"
  description   = "Cloud SQL Auth proxy for concourse-wgci"
  disabled      = "false"
  display_name  = "Cloud SQL Auth proxy"
  project       = var.project
}

resource "google_project_iam_member" "cloud-sql-auth-proxy" {
  project = var.project
  member  = "serviceAccount:${google_service_account.cloud-sql-auth-proxy.email}"
  role    = "roles/cloudsql.client"
}

resource "google_service_account_iam_member" "cloud-sql-auth-proxy" {
  service_account_id = google_service_account.cloud-sql-auth-proxy.id
  member             = "serviceAccount:${var.project}.svc.id.goog[concourse/cloud-sql-auth-proxy]"
  role               = "roles/iam.workloadIdentityUser"
}

resource "kubernetes_service_account" "cloud-sql-auth-proxy" {
  metadata {
    name = "cloud-sql-auth-proxy"
    namespace = "concourse"
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.cloud-sql-auth-proxy.email}"
    }
  }
}

resource "kubernetes_namespace" "concourse" {
  metadata {
    name = "concourse"
  }
}