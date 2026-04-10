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
        # VCS tools
        pkgs.vscode-marketplace.jjk.jjk

        # Language support
        pkgs.vscode-marketplace.foxundermoon.shell-format
        jnoortheen.nix-ide
        redhat.vscode-yaml
        timonwong.shellcheck
        llvm-vs-code-extensions.vscode-clangd
        tamasfe.even-better-toml
        davidanson.vscode-markdownlint

        # General dev tools
        dnut.rewrap-revived
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers

        # Cosmetic
        t3dotgg.vsc-material-theme-but-i-wont-sue-you
      ];
      userSettings = {
        # Visual
        workbench.colorTheme = "Material Theme Darker High Contrast";
        editor.fontFamily = "FiraCode Nerd Font Mono";
        materialTheme.accent = "Tomato";
        workbench.colorCustomizations = (builtins.fromJSON (builtins.readFile ./workbench.colorCustomizations.jsonc));
        workbench.sideBar.location = "right";
        editor.fontLigatures = "'ss01', 'ss03', 'ss05', 'ss07', 'ss10'";

        # Code style
        editor.rulers = [ 80 ];

        # Tool choice preferences
        git.enabled = false;  # I use JJ
        C_Cpp.intelliSenseEngine = "disabled";
        "[shellscript]".editor.defaultFormatter = "foxundermoon.shell-format";


        # Point extensions at Nix versions of stuff
        shellcheck.executablePath = lib.getExe pkgs.shellcheck;
      };

    };
  };

  # Packages that are hard dependencies of my VsCode extensions actually working
  # (either because the extension depends on them, or because the extension
  # wants to bundle a binary that won't run on NixOS.)
  #
  # TODO: Consider migrating this stuff out into specific workflows / mixins per
  # language.
  home.packages = [
    pkgs.shellcheck
  ];
}
