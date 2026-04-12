# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  modules,
  secrets,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services/photoprism
    "${modules}/common/host"
    "${modules}/programs/podman"
    "${modules}/services/avahi"
    "${modules}/services/crafty-controller"
    "${modules}/workflows/luks-cryptenroll"
  ];

  workflows.luksCryptenroll = {
    enable = true;
    devices.cryptroot = "baed883d-6a29-4a4f-b35a-39b3528589b9";
  };

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    # Note, we do not enable systemd-boot here because lanzeboote does that for us
  };
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

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
  services.openssh.settings = {
    AllowAgentForwarding = true;
    PasswordAuthentication = false;
    PermitRootLogin = "no";
    KbdInteractiveAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];

  # TODO: Consider removing this once I no longer need vscode-remote.
  programs.nix-ld.enable = true;

  # Configure automatic Cloudflare DNS updates
  age.secrets.cloudflare-dns-thooloocraft-token.file = "${secrets}/cloudflare-dns-thooloocraft-token.age";
  services.ddclient = {
    enable = true;
    interval = "5min";
    protocol = "cloudflare";
    username = "token";
    passwordFile = config.age.secrets.cloudflare-dns-thooloocraft-token.path;
    domains = [ "fuck-dynasty.thoolooexpress.com" ];
    zone = "thoolooexpress.com";
    ssl = true;
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    mdadm
    mokutil
    sbctl
  ];

  system.stateVersion = "25.11"; # Did you read the comment?
}
