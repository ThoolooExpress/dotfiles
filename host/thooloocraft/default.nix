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
# TODO: Move this cryptenroller stuff to a more generic module (with config options for devices labels)
let
  luks-cryptenroll = pkgs.writeTextFile {
    name = "luks-cryptenroll";
    destination = "/bin/luks-cryptenroll";
    executable = true;

    # Note: You can hardcode additional LUKS devices like so:
    # text = let
    #   ...
    #   luksDevice02 = "BEEGLUKS01";
    #   luksDevice03 = "BEEGLUKS02";
    # in ''
    #   ...
    #   sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-label/${luksDevice02}
    #   sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-label/${luksDevice03}
    # '';

    # Checking PCRs 0 and 7 (BIOS version and secure boot state). Could be more secure to also check 4,
    # to verify the bootloader itself, but that is much less stable.
    text =
      let
        luksDevice01 = "/dev/md0";
      in
      ''
        sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/md0
      '';
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${modules}/common/host"
    "${modules}/programs/podman"
    "${modules}/services/avahi"
    "${modules}/services/crafty-controller"
  ];

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

  # Stuff to manage filesystems.
  # TODO: When I'm done with this, either move to a shared module
  # or just remove.
  environment.systemPackages = with pkgs; [
    btrfs-progs
    mdadm
    cryptsetup
    mokutil
    sbctl
    luks-cryptenroll
  ];

  system.stateVersion = "25.11"; # Did you read the comment?
}
