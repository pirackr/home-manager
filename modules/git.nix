{ config, pkgs, lib, ... }:

{
  options.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
  };

  config = lib.mkIf config.modules.git.enable {
    programs.git = {
      enable = true;
      userName = "username";
      userEmail = "user@mail.com";
    };
  };
}
