{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    google-cloud-sdk
    kapp
    kubectl
    kubernetes-helm
    terraform
    terragrunt
    vendir
    ytt
  ];
}
