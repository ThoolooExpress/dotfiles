# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  modules,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${modules}/common/host"
    "${modules}/programs/podman"
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking = {
    hostName = "thooloocraft";
    networkmanager.enable = true;
  };

  # Locale / TZ
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 8022 ];
  services.openssh.settings = {
    AllowAgentForwarding = true;
    PasswordAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8022 ];

  # TODO: Consider removing this once I no longer need vscode-remote.
  programs.nix-ld.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
