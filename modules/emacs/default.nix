{ config, lib, pkgs, ... }:

{
  imports = [
    ./emacs-init.nix
  ];

  options.modules.emacs = {
    enable = lib.mkEnableOption "Emacs configuration";
  };

  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs = {
      enable = true;
      
      # Enable the init configuration system
      init = {
        enable = true;
        
        # Use-package configurations
        usePackage = {
          ag = {
            enable = true;
            extraPackages = [ pkgs.silver-searcher ];
          };
        };
        
        # Basic configuration in prelude (read from file)
        prelude = builtins.readFile ./prelude.el;
      };
    };
  };
}
