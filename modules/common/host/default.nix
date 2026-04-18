{ pkgs, ... }:

{
  # Set dvorak keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "dvorak";
  };

  console.keyMap = "dvorak";
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
      # thoolooframe key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMhNwHLC4plBDsVdPDChGlxwTCr6/WS5hsK7D6tbDmJd thoolooexpress@thoolooframe"
    ];
    shell = pkgs.zsh;
  };

  # Packages I almost always need
  # Some are  made redundant by my home-manager config
  # but as long as the `follows` in the flake is set up
  # correctly this shouldn't actually duplicate anything.
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    git
    vim
    file
    jujutsu
  ];

  # Stuff that really should be on by default at this point
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ZSH Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Set up SSH sudo
  security.sudo.enable = true;
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # Can't get away from this shit...
  programs.nix-ld.enable = true;
}
