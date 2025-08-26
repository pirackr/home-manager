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
        
        # Basic configuration in prelude
        prelude = ''
          ;; Basic UI Customizations
          (tool-bar-mode -1)      ; Disable toolbar
          (menu-bar-mode -1)      ; Disable menubar
          (scroll-bar-mode -1)    ; Disable scrollbars

          (savehist-mode +1)
          (recentf-mode +1)
          (save-place-mode +1)

          (setq inhibit-startup-message t) ; Disable startup message
          (setq initial-scratch-message nil) ; Clear scratch buffer message
          (global-display-line-numbers-mode 1) ; Enable line numbers globally

          ;; Indentation settings
          (setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
          (setq-default tab-width 4)         ; Set tab width to 4 spaces

          ;; Revert buffers automatically 
          (global-auto-revert-mode t)

          ;; highlight the current line
          (global-hl-line-mode 1)
        '';
      };
    };
  };
}
