{ config, pkgs, lib, ... }:

{
  options.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
  };

  config = lib.mkIf config.modules.git.enable {
    programs.git = {
      enable = true;
      settings.user = {
        name= "username";
        email= "user@mail.com";
      };
    };
  };
}
