{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/programs/atuin"
    "${modules}/programs/eza"
    "${modules}/programs/jujutsu"
    "${modules}/programs/neovim"
    "${modules}/programs/zsh"
    "${modules}/workflows/claude-code"
    "${modules}/workflows/datadog"
    "${modules}/workflows/k8s"
  ];

  home.username = "bits";
  home.homeDirectory = "/home/bits";
  home.stateVersion = "26.05";

  home.activation.backupFileExtension = "bak";
}
