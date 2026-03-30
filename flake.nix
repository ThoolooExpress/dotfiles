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
    {
      # Nixpkgs configuration
      nixpkgsConfig = {
        allowUnfree = true;
      };

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
        "dog@richard-morrill" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [ ./home/dd-workspace ];
        };
      };
    };
}
