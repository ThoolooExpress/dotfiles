{
  description = "thoolooframe (Personal Laptop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    modules.url = "path:../../modules";
    secrets = {
      url = "path:../../secrets";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      nix-vscode-extensions,
      modules,
      secrets,
      lanzaboote,
      ...
    }:
    let
      lib = nixpkgs.lib;
    in
    {
      homeConfigurations = {
        "thoolooexpress@thoolooframe" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit modules secrets;
          };
          modules = [
            ./home
            agenix.homeManagerModules.default
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
              }
            )
          ];
        };
      };

      nixosConfigurations = {
        thoolooframe = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit modules secrets;
          };
          modules = [
            ./host
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
            }
            lanzaboote.nixosModules.lanzaboote
          ];
        };
      };
    };
}
