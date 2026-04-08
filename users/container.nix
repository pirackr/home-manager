{ config, lib, pkgs, ... }:

{
  home.username = "dev";
  home.homeDirectory = "/home/dev";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.file = {
    # Expose the mounted host home-manager tree inside the container.
    ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink "/mnt/home-manager";
  };
}
