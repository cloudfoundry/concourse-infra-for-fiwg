# resource "kubernetes_manifest" "cnrm" {
#     manifest = {
#         apiVersion = "core.cnrm.cloud.google.com/v1beta1"
#         kind = "ConfigConnector"
#         metadata = {
#             "name" = "configconnector.core.cnrm.cloud.google.com"
#         }
#         spec = {
#             mode = "cluster"
#             googleServiceAccount = "${google_service_account.cnrm-system.name}"

#         }
#     }
  
# }


# apiVersion: core.cnrm.cloud.google.com/v1beta1
# kind: ConfigConnector
# metadata:
#   name: configconnector.core.cnrm.cloud.google.com
# spec:
#  mode: cluster
#  googleServiceAccount: #@ "cnrm-system@" + data.values.google.project_id + ".iam.gserviceaccount.com"

