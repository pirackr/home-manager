{ config, pkgs, lib, ... }:

{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };

  config = lib.mkIf config.modules.hyprland.enable {
    # Only enable on Linux systems
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "Hyprland module requires a Linux system";
      }
    ];

    # This is just a placeholder module
    # Actual Hyprland configuration would go here when needed
    home.packages = with pkgs; lib.optionals stdenv.isLinux [
      # Add hyprland packages here when needed
    ];
  };
}
