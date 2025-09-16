{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url   = "github:nix-community/nixGL";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { nixpkgs, home-manager, flake-utils, nixgl, mac-app-util, ... }:
    {
      homeConfigurations = {
        "pirackr@work" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
          };
          modules = [
            mac-app-util.homeManagerModules.default
            ./modules/common.nix
            ./users/work.nix
          ];
          extraSpecialArgs = {
            inherit nixpkgs;
            };
          };

        "pirackr@home" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
          };
          modules = [
            ./modules/common.nix
            ./users/home.nix
          ];
          extraSpecialArgs = {
            inherit nixpkgs;
            nixgl = nixgl;
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
