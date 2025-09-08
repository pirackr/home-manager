{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Language Server Protocol client
      eglot = {
        enable = true;
        package = epkgs: epkgs.eglot;
        hook = [
          "(scala-ts-mode . eglot-ensure)"
          "(java-mode . eglot-ensure)"
          "(yaml-ts-mode . eglot-ensure)"
          "(go-ts-mode . eglot-ensure)"
          "(python-mode . eglot-ensure)"
          "(nix-mode . eglot-ensure)"
          "(terraform-mode . eglot-ensure)"
          "(haskell-ts-mode . eglot-ensure)"
        ];
        config = ''
          ;; Performance tuning for eglot
          (setq gc-cons-threshold 100000000) ;; 100mb
          (setq read-process-output-max (* 1024 1024)) ;; 1mb
          
          ;; Configure eglot server programs
          (add-to-list 'eglot-server-programs '(scala-ts-mode . ("metals")))
          (add-to-list 'eglot-server-programs '(python-mode . ("basedpyright" "--langserver")))
          (add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
          (add-to-list 'eglot-server-programs '(terraform-mode . ("terraform-ls" "serve")))
          (add-to-list 'eglot-server-programs '(haskell-ts-mode . ("haskell-language-server-wrapper" "--lsp")))
          
          ;; Eglot configuration
          (setq eglot-autoshutdown t)
          (setq eglot-sync-connect nil)
          (setq eglot-extend-to-xref t)
          
          ;; Use flymake (eglot's default) instead of flycheck
          (setq eglot-stay-out-of '(flycheck))
          
          ;; Additional eglot configuration
          (setq eglot-events-buffer-size 0) ;; Disable events buffer for performance
          (setq eglot-ignored-server-capabilities '(:hoverProvider))
        '';
      };

      # Eglot performance booster
      eglot-booster = {
        enable = true;
        package = epkgs: epkgs.eglot-booster;
        after = [ "eglot" ];
        config = ''
          ;; Enable eglot-booster for better performance
          (eglot-booster-mode 1)
        '';
      };

      # Debug Adapter Protocol
      dap-mode = {
        enable = true;
        package = epkgs: epkgs.dap-mode;
        config = ''
          ;; Enable dap-mode and dap-ui-mode globally for supported languages
          (dap-mode 1)
          (dap-ui-mode 1)
          (dap-tooltip-mode 1)
        '';
      };

      # Language modes
      scala-ts-mode = {
        enable = true;
        package = epkgs: epkgs.scala-mode; # Use scala-mode instead
        mode = [ "\\.scala\\'" ];
      };

      sbt-mode = {
        enable = true;
        package = epkgs: epkgs.sbt-mode;
        command = [ "sbt-start" "sbt-command" ];
        config = ''
          ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
          ;; allows using SPACE when in the minibuffer
          (substitute-key-definition
           'minibuffer-complete-word
           'self-insert-command
           minibuffer-local-completion-map)
           ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
           (setq sbt:program-options '("-Dsbt.supershell=false"))
        '';
      };

      go-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in package in newer Emacs
      };

      # Python development
      poetry = {
        enable = true;
        package = epkgs: epkgs.poetry;
      };

      yapfify = {
        enable = true;
        package = epkgs: epkgs.yapfify;
        defer = true;
        hook = [ "(python-mode . yapf-mode)" ];
      };

      # Nix support
      nix-mode = {
        enable = true;
        package = epkgs: epkgs.nix-mode;
      };

      # Infrastructure as Code
      hcl-mode = {
        enable = true;
        package = epkgs: epkgs.hcl-mode;
      };

      terraform-mode = {
        enable = true;
        package = epkgs: epkgs.terraform-mode;
        config = ''
          (defun my-terraform-mode-init ()
            ;; if you want to use outline-minor-mode
            (outline-minor-mode 1)
            )
          (add-hook 'terraform-mode-hook 'my-terraform-mode-init)
        '';
      };

      # Additional development utilities
      posframe = {
        enable = true;
        package = epkgs: epkgs.posframe;
      };
    };
  };
}