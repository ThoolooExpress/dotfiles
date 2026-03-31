# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Set dvorak keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "dvorak";
  };
  console.keyMap = "dvorak";


  # 
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;

  # My personal user account
  # IMPORTANT: If this is a system that I'll use directly, set up a password hash file in the host config.
  users.users.thoolooexpress = {
    isNormalUser = true;
    description = "Richard Morrill";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      # thooloohive key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1LG36pG0TZnU5A+8gXv7un2S13jprcFL3Zb2r7qCn1 morrill@thoolooexpress.com"
    ];
    shell = pkgs.zsh;
  };

  # Packages I almost always need
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    git
  ];

  # Stuff that really should be on by default at this point
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ZSH Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
