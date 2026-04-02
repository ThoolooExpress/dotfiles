# Installs the opencode package, and does a custom config setup. At some point
# this should probably be migrated to use a more full-featured setup, but right
# now none of them seem mature enough.
{ pkgs, lib, config, ... }:
{
  options.workflows.opencode.settings = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
    description = "Attribute set merged into ~/.config/opencode/opencode.json as JSON.";
  };

  config.home.packages = [
    pkgs.opencode
  ];

  config = {
    workflows.opencode.settings = {
      disabled_providers = [ "opencode" ];
      share = "disabled";
      permission = {
        edit = "ask";
        bash = {
          "*" = "ask";
        };
        webfetch = "ask";
        doom_loop = "ask";
        external_directory = "ask";
      };
    };
  };

  config.home.file = {
    ".config/opencode/opencode.json".text = builtins.toJSON config.workflows.opencode.settings;
  };

}
