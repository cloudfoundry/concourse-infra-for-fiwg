
data "carvel_ytt" "concourse_app" {

  files = [
    #"../../config/carvel-secretgen-controller",
    "../../config/concourse",
    "../../config/credhub",
    #"../../config/database",
    "../../config/uaa",
    "../../config/values",
    ]

  values = {
    "google.project_id" = var.project
    "google.region"     = var.region
  }
}


resource "carvel_kapp" "concourse_app" {
  app          = "concourse-app"
  namespace    = "concourse"
  config_yaml  = data.carvel_ytt.concourse_app.result
  diff_changes = true

  #depends_on = [kubernetes_namespace.concourse]

  delete {
    # WARN: if you change delete options you have to run terraform apply first.
    raw_options = ["--filter={\"and\":[{\"not\":{\"resource\":{\"kinds\":[\"Namespace\"]}}}]}"]
  }
}
