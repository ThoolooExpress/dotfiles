{
  lib,
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;
  };

  extensions = with pkgs.vscode-extensions; {
    jjk.jjk
    jnoortheen.nix-ide
  }
}
