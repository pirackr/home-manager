{ config, pkgs, lib, ... }:

{
  # User-specific configuration for hhnguyen
  # Add any user-specific packages, settings, or overrides here
  
  # Example: User-specific packages
  home.packages = with pkgs; [
    # Add user-specific packages here
  ];

  # Example: User-specific git configuration
  programs.git = {
    userName = lib.mkForce "pirackr";
    userEmail = lib.mkForce "pirackr.inbox@axon.com";  # Replace with actual email
  };

  # User-specific configurations can override or extend common settings
  modules = {
    # Example: Enable/disable specific modules for this user
    # hyprland.enable = true;  # Uncomment if this user needs Hyprland
    vim.enable = true;  # Enable vim for this user
    git.enable = true;  # Enable git for this user
    fish.enable = true;  # Enable fish for this user
    hyprland.enable = true;  # Disabled by default
    k8s.enable = true;  # Enable Kubernetes tools
  };
}
