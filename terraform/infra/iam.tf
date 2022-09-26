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

resource "google_project_iam_binding" "project-binding" {

  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityUser"
    ])
  role               = each.key

  members = [ "serviceAccount:${var.project}.svc.id.goog[${google_service_account.cnrm-system.name}/cnrm-controller-manager"]
  project       = var.project
}