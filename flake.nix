{
  description = "Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
    in {
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
        "bits@richard-morrill" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs = {
            modules = ./modules;
          };
          modules = [ ./home/dd-workspace ];
        };

        # "thooloocraft" (Personal Linux Server)
        "thoolooexpress@thooloocraft" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
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
          modules = [ ./host/thooloocraft ];
        };
      };
    };
}
