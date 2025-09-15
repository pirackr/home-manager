{ config, pkgs, lib, ... }:

{
  imports = [
    ./gtk.nix
    ./mako.nix
    ./hyprlock.nix
    ./waybar.nix
    ./rofi.nix
    ./hyprland.nix
  ];

  # UI module enable options
  options.modules.ui = {
    enable = lib.mkEnableOption "Enable all UI components";
  };

  config = lib.mkIf config.modules.ui.enable {
    # Enable all UI components when ui.enable is true
    modules.ui = {
      gtk.enable = lib.mkDefault true;
      mako.enable = lib.mkDefault true;
      hyprlock.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
      rofi.enable = lib.mkDefault true;
      hyprland.enable = lib.mkDefault true;
    };
  };
}