{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { nixpkgs, home-manager, flake-utils, mac-app-util, ... }:
    {
      homeConfigurations = {
        "pirackr@work" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
          modules = [
            mac-app-util.homeManagerModules.default
            ./modules/common.nix
            ./users/work.nix
          ];
          extraSpecialArgs = {
            inherit nixpkgs;
            };
          };

        "pirack@home" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [
            ./modules/common.nix
            ./users/home.nix
          ];
          extraSpecialArgs = {
            inherit nixpkgs;
          };
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Add development tools here
          ];
        };
      });
}
