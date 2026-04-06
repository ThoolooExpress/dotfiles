{ pkgs, modules, config, ... }:
{
  imports = [
    # Basic shell / vcs / editor setup
    "${modules}/programs/atuin"
    "${modules}/programs/eza"
    "${modules}/programs/jujutsu"
    "${modules}/programs/neovim"
    "${modules}/programs/zsh"
  ];

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.nixfmt
    pkgs.cowsay
    pkgs.nerd-fonts.fira-code
    pkgs.git
  ];
}
