{ pkgs, modules, nixpkgs, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/programs/sandbox-runtime"
    "${modules}/programs/vscode"
    "${modules}/workflows/opencode"
    "${modules}/workflows/claude-code"
    "${modules}/workflows/datadog"
    "${modules}/workflows/k8s"
  ];

  home.username = "richard.morrill";
  home.homeDirectory = "/Users/richard.morrill";
  home.stateVersion = "26.05";

  # At this point, this is the only non-Nix sytem I use topgrade on.
  # TODO: Migrate topgrade to a more general module if I can make sure it won't
  # screw things up on other systems
  home.packages = [
    pkgs.topgrade
  ];
  xdg.configFile."topgrade.toml".text = builtins.readFile ./topgrade.toml;

  programs.jujutsu.settings = {
    signing = {
      behavior = "own";
      backend = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFW/Fy5ywr4XELGpjGUDCXCqR0axBG7zS5skHabXn2F";
    };

    fsmonitor = {
      backend = "watchman";
      watchman.register-snapshot-trigger = true;
    };

    ui = {
      default-command = "log";
      merge-editor = "vscode";
    };

    # TODO: Find a better solution for switching on and off different merge
    # tools.
    merge-tools.idea = {
      program = "/Users/richard.morrill/Applications/IntelliJ IDEA Ultimate.app/Contents/MacOS/idea";
      diff-args = [
        "diff"
        "$left"
        "$right"
      ];
      edit-args = [
        "diff"
        "$left"
        "$right"
      ];
      merge-args = [
        "merge"
        "$left"
        "$right"
        "$base"
        "$output"
      ];
    };
  };

  programs.zsh = {
    # This is extra content that was in my .zshenv before I started using Nix.
    # TODO: Determine how much of this stuff can just be migrated to Nix.
    envExtra = ''
      . "$HOME/.cargo/env"
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"
    '';

    initContent = ''
      # Force the Nix binpaths to be first. This duplicates them in $PATH, but
      # I don't have a less dirty solution to this.
      export PATH="/Users/richard.morrill/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

      # Add the .local/bin directory to the $PATH, but put it last because
      # otherwise it could interfere with Nix stuff.
      export PATH="$PATH:$HOME/.local/bin"

      export GITLAB_TOKEN=$(security find-generic-password -a ''${USER} -s gitlab-token -w)

      # TODO: See if there's a better way to set this if I migrate Docker to
      # be managed by Nix.
      fpath=(/Users/richard.morrill/.docker/completions $fpath)

      # TODO: Determine if there's a need to set this up differently so it'll
      # work on Workspaces.
      eval "$(dd-gitsign load-key)"
    '';
  };

  # This path is only correct on this specific machine.
  # TODO: If I want to do Claude plugin development on more machines, find a way
  # to make this work in the base config.
  workflows.claudeCode.settings.extraKnownMarketplaces = {
    datadog-claude-plugins-dev = {
      source = {
        source = "directory";
        path = "/Users/richard.morrill/dd/claude-marketplace/dev";
      };
    };
  };

  programs.sandbox-runtime.enable = true;

  # This is an attempt to make my nix-shell invocations use the pinned sha from
  # my flake.
  # TODO: If this works well, do it everywhere else
  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${nixpkgs}";
  };
}
