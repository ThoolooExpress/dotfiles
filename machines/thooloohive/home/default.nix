{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/workflows/personal-development"
  ];

  programs.jujutsu.settings.signing = {
    behavior = "own";
    backend = "ssh";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1LG36pG0TZnU5A+8gXv7un2S13jprcFL3Zb2r7qCn1 morrill@thoolooexpress.com";
  };

  home.username = "thoolooexpress";
  home.homeDirectory = "/home/thoolooexpress";
  home.stateVersion = "26.05";
}
