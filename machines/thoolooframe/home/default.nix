{ pkgs, modules, secrets, config, ... }:
{
  imports = [
    "${modules}/common-desktop-nixos/home"
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

  age.secrets.thoolooframe-openrouter-key.file = "${secrets}/thoolooframe-openrouter-key.age";
  home.sessionVariables = {
    OPENROUTER_API_KEY = "$(cat ${config.age.secrets.thoolooframe-openrouter-key.path})";
  };

  services.ssh-agent.enable = true;
}