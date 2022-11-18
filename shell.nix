{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    kapp
    kubectl
    kubernetes-helm
    terraform
    terragrunt
    vendir
    ytt
    nodePackages.snyk
  ];
}
