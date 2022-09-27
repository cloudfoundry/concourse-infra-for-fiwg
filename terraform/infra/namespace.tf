resource "kubernetes_namespace" "concourse" {
  metadata {
    name = "concourse"
  }
}