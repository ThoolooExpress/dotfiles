{
  description = "thooloohive (personal gaming desktop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    modules.url = "path:../../modules";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      modules,
      ...
    }:
    {
      homeConfigurations = {
        "thoolooexpress@thooloohive" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs = {
            inherit modules;
          };
          modules = [ ./home ];
        };
      };
    };
}
