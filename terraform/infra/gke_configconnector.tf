resource "kubernetes_manifest" "cnrm" {
    manifest = {
        apiVersion = "core.cnrm.cloud.google.com/v1beta1"
        kind = "ConfigConnector"
        metadata = {
            "name" = "configconnector.core.cnrm.cloud.google.com"
        }
        spec = {
            mode = "cluster"
            googleServiceAccount = "${google_service_account.cnrm-system.email}"

        }
    }
  
}

