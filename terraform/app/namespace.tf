# kapp requires namespace for deployment and slaps own labels and annotation
# we don't use `kubernetes_namespace` resource since it will attempt to modify the above
resource "kubectl_manifest" "namespace" {
    yaml_body = <<YAML
---
apiVersion: v1
kind: Namespace
metadata:
  name: concourse
YAML
}