{ pkgs, modules, ... }:
{
  environment.systemPackages = with pkgs; [
    vlc
    libvlc
  ];
}
