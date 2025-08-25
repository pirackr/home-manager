{ config, pkgs, lib, ... }:

{
  options.modules.vim = {
    enable = lib.mkEnableOption "Vim configuration";
  };

  config = lib.mkIf config.modules.vim.enable {
    programs.vim = {
      enable = true;
      settings = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
      };
      extraConfig = ''
        syntax on
        set clipboard=unnamedplus
      '';
    };
    
    home.sessionVariables = {
      EDITOR = "vim";
    };
  };
}
