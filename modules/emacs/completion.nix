{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Modern completion framework
      vertico = {
        enable = true;
        package = epkgs: epkgs.vertico;
        demand = true; # Load early for minibuffer
        custom = {
          vertico-scroll-margin = 0;
          vertico-count = 20;
          vertico-resize = true;
          vertico-cycle = true;
        };
        init = ''
          (vertico-mode)
          ;; Enable cycling for `vertico-next' and `vertico-previous'.
          (setq vertico-cycle t)
          ;; Use `consult-completion-in-region' if Vertico is enabled.
          (advice-add #'completion-in-region :override #'consult-completion-in-region)
        '';
      };

      # Completion style for flexible matching
      orderless = {
        enable = true;
        package = epkgs: epkgs.orderless;
        custom = {
          completion-styles = "'(orderless basic)";
          completion-category-defaults = "nil";
          completion-category-overrides = "'((file (styles partial-completion)))";
        };
      };

      # Rich annotations in the minibuffer
      marginalia = {
        enable = true;
        package = epkgs: epkgs.marginalia;
        demand = true; # Load early for minibuffer annotations
        init = ''
          (marginalia-mode)
        '';
        bind = {
          "M-A" = "marginalia-cycle";
        };
      };

      # Enhanced completion interface
      consult = {
        enable = true;
        package = epkgs: epkgs.consult;
        defer = true;
        bind = {
          # C-c bindings in `mode-specific-map'
          "C-c M-x" = "consult-mode-command";
          "C-c h" = "consult-history";
          "C-c k" = "consult-kmacro";
          "C-c m" = "consult-man";
          "C-c i" = "consult-info";
          # C-x bindings in `ctl-x-map'
          "C-x M-:" = "consult-complex-command";
          "C-x b" = "consult-buffer";
          "C-x 4 b" = "consult-buffer-other-window";
          "C-x 5 b" = "consult-buffer-other-frame";
          "C-x t b" = "consult-buffer-other-tab";
          "C-x r b" = "consult-bookmark";
          "C-x p b" = "consult-project-buffer";
          # M-# bindings for search
          "M-#" = "consult-register-load";
          "M-'" = "consult-register-store";
          "C-M-#" = "consult-register";
          # M-g bindings in `goto-map'
          "M-g e" = "consult-compile-error";
          "M-g f" = "consult-flymake";
          "M-g g" = "consult-goto-line";
          "M-g M-g" = "consult-goto-line";
          "M-g o" = "consult-outline";
          "M-g m" = "consult-mark";
          "M-g k" = "consult-global-mark";
          "M-g i" = "consult-imenu";
          "M-g I" = "consult-imenu-multi";
          # M-s bindings in `search-map'
          "M-s d" = "consult-find";
          "M-s c" = "consult-locate";
          "M-s g" = "consult-grep";
          "M-s G" = "consult-git-grep";
          "M-s r" = "consult-ripgrep";
          "M-s l" = "consult-line";
          "M-s L" = "consult-line-multi";
          "M-s k" = "consult-keep-lines";
          "M-s u" = "consult-focus-lines";
          # Isearch integration
          "M-s e" = "consult-isearch-history";
        };
        config = ''
          ;; Optionally configure the register formatting
          (setq register-preview-delay 0.5
                register-preview-function #'consult-register-format)

          ;; Optionally tweak the register preview window
          (advice-add #'register-preview :override #'consult-register-window)

          ;; Use Consult to select xref locations with preview
          (setq xref-show-xrefs-function #'consult-xref
                xref-show-definitions-function #'consult-xref)
        '';
      };

      # Completion framework
      company = {
        enable = true;
        package = epkgs: epkgs.company;
        defer = true;
        hook = [ "(prog-mode . company-mode)" "(text-mode . company-mode)" ];
        config = ''
          ;; (add-to-list 'company-backends 'company-nixos-options)
          ;; Configure company settings for better performance
          (setq company-idle-delay 0.3)
          (setq company-minimum-prefix-length 2)
          (setq company-tooltip-limit 10)
        '';
      };

      # Snippet system
      yasnippet = {
        enable = true;
        package = epkgs: epkgs.yasnippet;
        defer = true;
        hook = [ "(prog-mode . yas-minor-mode)" ];
        config = ''
          ;; Enable yasnippet integration with eglot
          (add-hook 'eglot-managed-mode-hook 'yas-minor-mode)
        '';
      };

      # Search and replace with visual feedback
      anzu = {
        enable = true;
        package = epkgs: epkgs.anzu;
        defer = true;
        bind = {
          "M-%" = "anzu-query-replace";
          "C-M-%" = "anzu-query-replace-regexp";
        };
        config = ''
          (global-anzu-mode)
        '';
      };

      # Save minibuffer history
      savehist = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in package
        init = ''
          (savehist-mode)
        '';
      };
   };
  };
}
