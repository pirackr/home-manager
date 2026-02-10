{ config, lib, pkgs, ... }:

let
  w = pkgs.writeShellApplication {
    name = "w";
    runtimeInputs = [ pkgs.stow pkgs.git pkgs.coreutils ];
    text = builtins.readFile ./w;
  };
in
{
  options.modules.workspace = {
    enable = lib.mkEnableOption "workspace override manager";
  };

  config = lib.mkIf config.modules.workspace.enable {
    home.packages = [ w ];
  };
}
