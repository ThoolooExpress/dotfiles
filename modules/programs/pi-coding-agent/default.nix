{ modules, ... }:
{
  home.file.".pi/agent/AGENTS.md".text = modules.lib.agentsMd;
}
