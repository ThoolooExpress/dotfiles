{ pkgs, config, ... }:
{
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.nixfmt
    pkgs.cowsay
    pkgs.nerd-fonts.fira-code
  ];

}
