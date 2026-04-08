{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/agents
  ];

  home.username = "dev";
  home.homeDirectory = "/home/dev";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.file = {
    # Keep generated agent symlinks valid inside the container by exposing the
    # mounted host home-manager tree at the path the shared module expects.
    ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink "/mnt/home-manager";
  };

  modules.agents = {
    enable = true;
  };
}
