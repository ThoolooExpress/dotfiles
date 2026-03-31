{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/programs/atuin"
    "${modules}/programs/eza"
    "${modules}/programs/jujutsu"
    "${modules}/programs/neovim"
    "${modules}/programs/vscode"
    "${modules}/programs/zsh"
    "${modules}/workflows/personal-development"
  ];

  home.username = "thoolooexpress";
  home.homeDirectory = "/home/thoolooexpress";
  home.stateVersion = "26.05";
}
