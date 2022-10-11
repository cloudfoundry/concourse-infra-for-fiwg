data "kubernetes_secret_v1" "credhub_encryption_key" {
  metadata {
    name      = var.dr.credhub_encryption_key_name
    namespace = var.concourse_app.namespace
  }

  binary_data = {
    password = ""
  }

}

output "credhub_encryption_key" {
    value = data.kubernetes_secret_v1.credhub_encryption_key
    sensitive = true
}


# ---
data "kubernetes_secret_v1" "credhub_config" {
  metadata {
    name      = var.dr.credhub_config_name
    namespace = var.concourse_app.namespace
  }

  binary_data = {
    "application.yml" = ""
  }
}

output "credhub_config" {
    value = data.kubernetes_secret_v1.credhub_config
    sensitive = true
}