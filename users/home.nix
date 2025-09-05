{ config, pkgs, nixgl, lib, ... }:

{
  # User-specific configuration for hhnguyen
  # Add any user-specific packages, settings, or overrides here

  home.username = "pirackr";
  home.homeDirectory = "/home/pirackr";

  # Example: User-specific packages
  home.packages = with pkgs; [
    # Add user-specific packages here
  ];

  nixGL.packages = nixgl.packages;

  programs.kitty = {
    package = (config.lib.nixGL.wrap pkgs.kitty);
    font.size = lib.mkForce 18;
  };

  # Example: User-specific git configuration
  programs.git = {
    userName = lib.mkForce "pirackr";
    userEmail = lib.mkForce "pirackr.inbox@gmail.com";  # Replace with actual email
  };

  # trace: warning: xdg-desktop-portal 1.18 reworked how portal implementations are loaded, you
  # should either set `xdg.portal.config` or `xdg.portal.configPackages`
  # to specify which portal backend to use for the requested interface.
  # https://github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
  # If you simply want to keep the behaviour in < 1.17, which uses the first
  # portal implementation found in lexicographical order, use the following:
  xdg.portal.config.common.default = "*";

 # User-specific configurations can override or extend common settings
  modules = {
    # Example: Enable/disable specific modules for this user
    # hyprland.enable = true;  # Uncomment if this user needs Hyprland
    vim.enable = true;  # Enable vim for this user
    git.enable = true;  # Enable git for this user
    fish.enable = true;  # Enable fish for this user
    hyprland.enable = true;  # Disabled by default
    k8s.enable = true;  # Enable Kubernetes tools
    emacs.enable = true;
    fcitx.enable = true;
  };
}
