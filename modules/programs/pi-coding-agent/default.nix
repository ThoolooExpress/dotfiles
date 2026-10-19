{
  config,
  lib,
  options,
  ...
}:
{
  home.file =
    lib.mkIf (options.programs ? pi-coding-agent && config.programs.pi-coding-agent.enable)
      {
        "${config.programs.pi-coding-agent.configDir}/skills/pr-description-links".source =
          ./skills/pr-description-links;
        "${config.programs.pi-coding-agent.configDir}/skills/personal-change-description-style".source =
          ./skills/personal-change-description-style;
      };
}
