{ config, lib, pkgs, ... }:

let
  # Base path for scripts (for runtime reading)
  scriptsPath = "${config.home.homeDirectory}/.config/home-manager/modules/scripts";

  # Create script packages
  scriptPackages = {
    splunk-query = pkgs.writeScriptBin "splunk-query"
      (builtins.readFile ./splunk-query);
workspace = pkgs.writeShellApplication {
      name = "workspace";
      runtimeInputs = [ pkgs.stow pkgs.git pkgs.coreutils ];
      text = builtins.readFile ./workspace;
    };
  };
in
{
  options.modules.scripts = {
    enable = lib.mkEnableOption "utility scripts";
  };

  config = lib.mkIf config.modules.scripts.enable {
    # Install all utility scripts
    home.packages = builtins.attrValues scriptPackages;
  };
}
