{ pkgs, modules, ... }:
{
  imports = [
    ./bzl-bazel.nix
    ./identity.nix
    ./redirect-managed-zsh.nix
    ./k8s-docker-aliases.nix
  ];
}
