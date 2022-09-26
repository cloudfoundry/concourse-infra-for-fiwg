resource "google_service_account" "autoscaler_deployer" {
  account_id    = "autoscaler-deployer"
  description   = "Used by concourse ci to deploy autoscaler service+infra"
  disabled      = "false"
  display_name  = "autoscaler-deployer"
  project       = var.project
}

# resource "google_service_account" "concourse" {
#   account_id    = "concourse"
#   description   = "concourse deployment on wg-ci gke"
#   disabled      = "false"
#  project       = var.project
# }

resource "google_service_account" "cnrm-system" {
  account_id    = "cnrm-system"
  description   = "Config Connector account for wg-ci GKE"
  disabled      = "false"
  project       = var.project
}


resource "google_project_iam_member" "cnrm-system" {
  project = var.project
  member  = "serviceAccount:${google_service_account.cnrm-system.email}"
  role    = "roles/iam.serviceAccountAdmin"
}

resource "google_service_account_iam_member" "cnrm-system" {
  service_account_id = google_service_account.cnrm-system.id
  member             = "serviceAccount:${var.project}.svc.id.goog[cnrm-system/cnrm-controller-manager-wg-ci]"
  role               = "roles/iam.workloadIdentityUser"
}


# TODO:
# resource "google_project_iam_custom_role" "wg-ci-role" {
#   description = "Permissions needed to manage wg-ci project"
#   permissions = [ ... ]
#   project     = var.project
#  role_id     = "WgCiCustomRole"
#  stage       = "GA"
#  title       = "WG CI Manage"
#}