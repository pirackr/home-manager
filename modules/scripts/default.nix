{ config, lib, pkgs, ... }:

let
  # Base path for scripts (for runtime reading)
  scriptsPath = "${config.home.homeDirectory}/.config/home-manager/modules/scripts";

  # Create script packages
  scriptPackages = {
    quip2markdown = pkgs.writeScriptBin "quip2markdown"
      (builtins.readFile ./quip2markdown);
    markdown2quip = pkgs.writeScriptBin "markdown2quip"
      (builtins.readFile ./markdown2quip);
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
