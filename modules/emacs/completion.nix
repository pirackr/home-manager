{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Modern completion framework
      vertico = {
        enable = true;
        package = epkgs: epkgs.vertico;
        defer = true;
        custom = {
          vertico-scroll-margin = 0;
          vertico-count = 20;
          vertico-resize = true;
          vertico-cycle = true;
        };
        init = ''
          (add-hook 'after-init-hook #'vertico-mode)
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
        defer = true;
        init = ''
          (add-hook 'after-init-hook #'marginalia-mode)
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
      corfu = {
        enable = true;
        package = epkgs: epkgs.corfu;
        defer = true;
        bindLocal = {
          corfu-map = {
            "RET" = "corfu-insert";
            "TAB" = "corfu-complete";
            "C-n" = "corfu-next";
            "C-p" = "corfu-previous";
            "M-d" = "corfu-info-documentation";
            "M-l" = "corfu-info-location";
          };
        };
        config = ''
          ;; Default to manual completion to avoid CAPF churn in every buffer.
          (setq corfu-auto nil)
          (setq corfu-auto-delay 0.12)
          (setq corfu-auto-prefix 2)
          (setq corfu-min-width 20)
          (setq corfu-max-width 100)
          (setq corfu-count 10)
          (setq corfu-scroll-margin 2)
          (setq corfu-cycle t)
          (setq corfu-preselect 'first)
          (setq corfu-on-exact-match nil)
          (setq corfu-echo-documentation 0.25)
          (setq tab-always-indent 'complete)
          (setq corfu-quit-at-boundary t)
          (setq corfu-quit-no-match t)

          (defun hm/corfu-prog-mode ()
            "Enable `corfu-mode' with manual triggering for programming buffers."
            (corfu-mode 1))

          (add-hook 'prog-mode-hook #'hm/corfu-prog-mode)
          (add-hook 'conf-mode-hook #'hm/corfu-prog-mode)

          (defun hm/corfu-eglot-toggle ()
            "Enable aggressive Corfu auto completion only when Eglot manages the buffer."
            (if eglot-managed-mode
                (progn
                  (corfu-mode 1)
                  (setq-local corfu-auto t)
                  (setq-local corfu-auto-prefix 1)
                  (setq-local corfu-quit-no-match nil))
              (setq-local corfu-auto nil)
              (setq-local corfu-auto-prefix 2)
              (setq-local corfu-quit-no-match t)))

          (with-eval-after-load 'eglot
            (add-hook 'eglot-managed-mode-hook #'hm/corfu-eglot-toggle))
        '';
      };

      # Corfu extensions for enhanced functionality
      cape = {
        enable = true;
        package = epkgs: epkgs.cape;
        after = [ "corfu" ];
        config = ''
          ;; Add useful completion at point functions
          (add-to-list 'completion-at-point-functions #'cape-dabbrev)
          (add-to-list 'completion-at-point-functions #'cape-file)
          (add-to-list 'completion-at-point-functions #'cape-elisp-block)
          (add-to-list 'completion-at-point-functions #'cape-history)
          (add-to-list 'completion-at-point-functions #'cape-keyword)
          (add-to-list 'completion-at-point-functions #'cape-abbrev)
        '';
      };

      # Corfu terminal support
      corfu-terminal = {
        enable = false;
        package = epkgs: epkgs.corfu-terminal;
        after = [ "corfu" ];
        config = ''
          ;; Enable corfu in terminal
          (unless (display-graphic-p)
            (corfu-terminal-mode +1))
        '';
      };

      # Kind icons for corfu
      kind-icon = {
        enable = true;
        package = epkgs: epkgs.kind-icon;
        after = [ "corfu" ];
        config = ''
          ;; Add kind icons to corfu
          (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
          ;; Customize kind icons
          (setq kind-icon-default-face 'corfu-default)
          (setq kind-icon-blend-background nil)
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
