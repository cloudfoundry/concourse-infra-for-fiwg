output "credhub_encryption_key_id" {
  value     = google_secret_manager_secret.credhub_encryption_key.id
  sensitive = false
}

# data "kubernetes_secret_v1" "credhub_config" {
#   metadata {
#     name      = var.dr.credhub_config_name
#     namespace = var.concourse_app.namespace
#   }
#   binary_data = {
#     "application.yml" = ""
#   }
# }

# data "kubernetes_secret_v1" "credhub_keystore_key" {
#   metadata {
#     name      = var.dr.credhub_keystore_key_name
#     namespace = var.concourse_app.namespace
#   }
#   binary_data = {
#     password = ""
#   }
# }

# data "kubernetes_secret_v1" "credhub_truststore_key" {
#   metadata {
#     name      = var.dr.credhub_truststore_key_name
#     namespace = var.concourse_app.namespace
#   }
#   binary_data = {
#     password = ""
#   }
# }



# # ---
# output "credhub_config" {
#   value     = data.kubernetes_secret_v1.credhub_config
#   sensitive = true
# }




# output "credhub_keystore_key" {
#   value     = data.kubernetes_secret_v1.credhub_keystore_key
#   sensitive = true
# }

# output "credhub_trusttore_key" {
#   value     = data.kubernetes_secret_v1.credhub_truststore_key
#   sensitive = true
# }
