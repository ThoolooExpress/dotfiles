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
    "${modules}/common/host"
    "${modules}/common-desktop-nixos/host"
    "${modules}/workflows/luks-cryptenroll"
  ];

  # Unclear if this is necessary, but can't hurt, right?
  hardware.graphics.enable = true;

  workflows.luksCryptenroll = {
    enable = true;
    devices.cryptroot = "69e7a964-4e37-47eb-aab1-07bc8c991cec";
    devices.cryptswap = "65a904f2-7e9a-410a-8031-ef7f237f78f4";
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
    hostName = "thoolooframe";
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Set hashed password (user already defined in common)
  age.secrets.thoolooexpress-login-hashed-password.file = "${secrets}/thoolooexpress-login-hashed-password.age";
  users.users.thoolooexpress.hashedPasswordFile =
    config.age.secrets.thoolooexpress-login-hashed-password.path;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Since we don't want to run an actual OpenSSH server here, just point
  # agenix at our system SSH key
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Enable resolving .local domains
  # TODO: Move this to a more generic block
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enables resolve-by-hostname (e.g., ping hostname.local)
    nssmdns6 = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    # LUKS / secure boot management stuff.
    # TODO: Move this to a common workflow
    cryptsetup
    mokutil
    sbctl
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
