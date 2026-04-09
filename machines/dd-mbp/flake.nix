{
  description = "dd-mbp (Work Mac)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    modules.url = "path:../../modules";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      modules,
      nix-vscode-extensions,
      ...
    }:
    {
      homeConfigurations = {
        "richard.morrill@redacted" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit modules;
          };
          modules = [
            ./home
            {
              nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
            }
          ];
        };
      };
    };
}
