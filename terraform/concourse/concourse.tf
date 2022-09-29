resource "kubernetes_namespace" "concourse" {
  metadata {
    name = "concourse"
  }

  lifecycle {
    ignore_changes = all
  }

}

data "carvel_ytt" "concourse" {

  files = ["../../config"]

  values = {
    "google.project_id" = var.project
    "google.region"     = var.region
  }
}


resource "carvel_kapp" "concourse" {
  app          = "concourse"
  namespace    = "concourse"
  config_yaml  = data.carvel_ytt.concourse.result
  diff_changes = true

  depends_on = [kubernetes_namespace.concourse]

  delete {
    raw_options = ["--filter='{\"and\":[{\"not\":{\"resource\":{\"kinds\":[\"Namespace\"]}}}]}'"]
  }
}

# view ytt yaml file with ie.
# terraform output result |grep -v EOT > ../../ytt_manifest-tf.yaml
# output "result" {
#   value = data.carvel_ytt.concourse.result
#   sensitive = true
# }
