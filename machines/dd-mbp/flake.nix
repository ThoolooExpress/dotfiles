{
  description = "dd-mbp (Work Mac)";

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
        "richard.morrill@redacted" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
          extraSpecialArgs = {
            inherit modules;
          };
          modules = [ ./home ];
        };
      };
    };
}
