{
  lib,
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        jjk.jjk
        jnoortheen.nix-ide
        t3dotgg.vsc-material-theme-but-i-wont-sue-you
      ];
      userSettings = {
        workbench.preferredColorTheme = "Material Theme Darker High Contrast";
        editor.fontFamily = "FiraCode Nerd Font Mono";
      };
    };
  };
}
