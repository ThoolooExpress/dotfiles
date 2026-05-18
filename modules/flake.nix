{
  description = "Shared NixOS and home-manager modules";
  inputs = { };
  outputs = { self, ... }: {
    lib.agentsMd = import ./lib/agents;
  };
}
