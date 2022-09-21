resource "google_service_account" "autoscaler_deployer" {
  account_id    = "autoscaler-deployer"
  description   = "Used by concourse ci to deploy autoscaler service+infra"
  disabled      = "false"
  display_name  = "autoscaler-deployer"
  project       = var.project
}