{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/programs/atuin"
    "${modules}/programs/eza"
    "${modules}/programs/jujutsu"
    "${modules}/programs/neovim"
    "${modules}/programs/zsh"
    "${modules}/programs/vscode"
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
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWnlUQ1Ruprl7ovHf7Mux55hvwMW3BRTfUTwv20xHBz morrill@thoolooexpress.com";
  };

  services.ssh-agent.enable = true;
}
