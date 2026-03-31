{ pkgs, ... }:

{
  # If this is a machine where I have a personal account, allow myself to use podman.
  # A no-op if this account hasn't been set as enabled somewhere else.
  users.users.thoolooexpress = {
    extraGroups = [
      "podman"
    ];
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      extraRuntimes = [
        pkgs.gvisor
      ];
    };
  };
}
