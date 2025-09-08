{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Modern completion framework
      vertico = {
        enable = true;
        package = epkgs: epkgs.vertico;
        custom = {
          vertico-scroll-margin = 0;
          vertico-count = 20;
          vertico-resize = true;
          vertico-cycle = true;
        };
        init = ''
          (vertico-mode)
        '';
      };

      # Enhanced completion interface
      consult = {
        enable = true;
        package = epkgs: epkgs.consult;
      };

      # Completion framework
      company = {
        enable = true;
        package = epkgs: epkgs.company;
        config = ''
          ;; (add-to-list 'company-backends 'company-nixos-options)
          (global-company-mode)
        '';
      };

      # Snippet system
      yasnippet = {
        enable = true;
        package = epkgs: epkgs.yasnippet;
        config = ''
          (yas-global-mode 1)
          ;; Enable yasnippet integration with eglot
          (add-hook 'eglot-managed-mode-hook 'yas-minor-mode)
        '';
      };

      # Search and replace with visual feedback
      anzu = {
        enable = true;
        package = epkgs: epkgs.anzu;
        bind = {
          "M-%" = "anzu-query-replace";
          "C-M-%" = "anzu-query-replace-regexp";
        };
        config = ''
          (global-anzu-mode)
        '';
      };

      # Fuzzy finder
      fzf = {
        enable = true;
        package = epkgs: epkgs.fzf;
      };
    };
  };
}