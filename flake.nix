{
  description = "Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, home-manager, ...}: {
      homeConfigurations = {
          "richard.morrill" = home-manager.lib.homeManagerConfiguration {
              # System is very important!
              pkgs = import nixpkgs { system = "aarch64-darwin"; };

              modules = [ ./home.nix ]; # Defined later
          };
      };
  };
}