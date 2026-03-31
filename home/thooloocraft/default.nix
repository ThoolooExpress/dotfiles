{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/programs/atuin"
    "${modules}/programs/eza"
    "${modules}/programs/jujutsu"
    "${modules}/programs/neovim"
    "${modules}/programs/zsh"
    "${modules}/workflows/personal-development"
  ];

  home.username = "thoolooexpress";
  home.homeDirectory = "/home/thoolooexpress";
  home.stateVersion = "26.05";

  # Use the thooloohive key (via ssh-agent) for jj commit signing.
  # This should probably be switched to my laptop's key at some point.
  programs.jujutsu.settings.signing = {
    behavior = "own";
    backend = "ssh";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1LG36pG0TZnU5A+8gXv7un2S13jprcFL3Zb2r7qCn1 morrill@thoolooexpress.com";
  };
}
