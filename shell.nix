{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.google-cloud-sdk
    pkgs.ytt
    pkgs.kapp
    pkgs.vendir
    pkgs.kubectl
    pkgs.kubernetes-helm
  ];
}
