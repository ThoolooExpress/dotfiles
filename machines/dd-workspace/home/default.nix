{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/workflows/claude-code"
    "${modules}/workflows/datadog"
    "${modules}/workflows/k8s"
  ];

  home.username = "bits";
  home.homeDirectory = "/home/bits";
  home.stateVersion = "26.05";

  # This is identical to my MBP config, since I always SSH into workspaces
  # from my work Macbook
  programs.jujutsu.settings = {
    signing = {
      behavior = "own";
      backend = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFW/Fy5ywr4XELGpjGUDCXCqR0axBG7zS5skHabXn2F";
    };
  };
}
