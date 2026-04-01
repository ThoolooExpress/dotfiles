{
  description = "Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # gVisor is pinned because of a build issue in the unstable branch.
    # TODO: Remove once https://github.com/NixOS/nixpkgs/pull/503624 is merged.
    pinnedGvisorVersion.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      pinnedGvisorVersion,
      ...
    }:
    # TODO: Remove once https://github.com/NixOS/nixpkgs/pull/503624 is merged.
    let
      pinnedGvisor = final: prev: {
        gvisor = pinnedGvisorVersion.legacyPackages.${prev.system}.gvisor;
      };
      lib = nixpkgs.lib;
    in
    {
      homeConfigurations = {
        # "dd-mbp" (Work Mac)
        "richard.morrill@redacted" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
          extraSpecialArgs = {
            modules = ./modules;
          };
          modules = [ ./home/dd-mbp ];
        };

        # "dd-workspace" (Work VM)
        "dd-workspace" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs = {
            modules = ./modules;
          };
          modules = [ ./home/dd-workspace ];
        };

        # "thooloocraft" (Personal Linux Server)
        "thoolooexpress@thooloocraft" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            modules = ./modules;
          };
          modules = [ ./home/thooloocraft ];
        };
      };

      nixosConfigurations = {
        thooloocraft = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            modules = ./modules;
          };
          modules = [
            ./host/thooloocraft
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ pinnedGvisor ];
              }
            )
          ];
        };
      };
    };
}
