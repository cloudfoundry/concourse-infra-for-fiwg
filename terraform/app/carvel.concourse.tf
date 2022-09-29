#data ""

resource "carvel_kapp" "concourse" {
    app = "concourse"
    namespace = "concourse"
    files = [ "../../ytt_manifest.yaml" ]

    depends_on = [ kubectl_manifest.namespace ]
}