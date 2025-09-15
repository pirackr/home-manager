{ config, pkgs, lib, ... }:

{
  options.modules.gtk = {
    enable = lib.mkEnableOption "GTK configuration with Catppuccin theme";
  };

  config = lib.mkIf config.modules.gtk.enable {
    home.packages = with pkgs; [
      catppuccin-gtk
      papirus-icon-theme
      catppuccin-cursors
    ];

    gtk = {
      enable = true;
      
      theme = {
        name = "catppuccin-frappe-lavender-standard+default";
        package = pkgs.catppuccin-gtk.override {
          accents = ["lavender"];
          size = "standard";
          tweaks = ["normal"];
          variant = "frappe";
        };
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      cursorTheme = {
        name = "catppuccin-frappe-dark-cursors";
        package = pkgs.catppuccin-cursors.frappeDark;
        size = 24;
      };

      font = {
        name = "Noto Sans";
        size = 11;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    # Configure qt applications to use GTK theme
    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style.name = "adwaita-dark";
    };

    # Set environment variables for consistent theming
    home.sessionVariables = {
      GTK_THEME = "catppuccin-frappe-lavender-standard+default";
      XCURSOR_THEME = "catppuccin-frappe-dark-cursors";
      XCURSOR_SIZE = "24";
    };

  };
}