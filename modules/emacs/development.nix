{ config, lib, pkgs, ... }:

{
  imports = [
    ./languages/python.nix
    ./languages/scala.nix
    ./languages/go.nix
    ./languages/nix.nix
    ./languages/terraform.nix
    ./languages/yaml.nix
  ];

  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Language Server Protocol client
      eglot = {
        enable = true;
        package = epkgs: epkgs.eglot;
        hook = [
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

          ;; Use flymake (eglot's default)
          (setq eglot-stay-out-of nil)

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

      # Language-specific configurations are now in separate modules
      # See languages/ directory for individual language setups
    };
  };
}
