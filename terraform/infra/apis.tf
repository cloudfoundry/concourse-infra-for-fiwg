# Set apis to not disable in case we issue `terraform destroy`
variable "apis" {
  type = list
  default = [
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(var.apis)
  service = each.key
  project = var.project
  disable_on_destroy = false
}
