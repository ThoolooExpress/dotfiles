{
  description = "thooloocraft (Personal Linux Server)";

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
    # gVisor is pinned because of a build issue in the unstable branch.
    # TODO: Remove once https://github.com/NixOS/nixpkgs/pull/503624 is merged.
    pinnedGvisorVersion = {
      url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
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
      pinnedGvisorVersion,
      agenix,
      lanzaboote,
      modules,
      secrets,
      ...
    }:
    let
      pinnedGvisor = final: prev: {
        gvisor = pinnedGvisorVersion.legacyPackages.${prev.system}.gvisor;
      };
      lib = nixpkgs.lib;
    in
    {
      homeConfigurations = {
        "thoolooexpress@thooloocraft" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit modules;
          };
          modules = [ ./home ];
        };
      };

      nixosConfigurations = {
        thooloocraft = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit modules secrets;
          };
          modules = [
            ./host
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ pinnedGvisor ];
              }
            )
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
