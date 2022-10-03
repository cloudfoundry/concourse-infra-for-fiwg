data "carvel_ytt" "concourse_app" {

  files = [
    "../../config/concourse",
    "../../config/credhub",
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

  # deploy {
  #   raw_options = ["--dangerous-override-ownership-of-existing-resources"]
  # }

  delete {
    # WARN: if you change delete options you have to run terraform apply first.
    raw_options = ["--filter={\"and\":[{\"not\":{\"resource\":{\"kinds\":[\"Namespace\"]}}}]}"]
  }
}
