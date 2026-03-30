{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  home.username = "dog";
  home.homeDirectory = "/home/dog";
  home.stateVersion = "26.05";
}
