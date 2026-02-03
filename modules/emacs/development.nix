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
        # Use builtin Eglot from Emacs to avoid ELPA conflicts
        package = epkgs: epkgs.emacs;
        hook = [
          "(haskell-ts-mode . eglot-ensure)"
          "(nix-mode . eglot-ensure)"
          "(go-ts-mode . eglot-ensure)"
          "(scala-ts-mode . eglot-ensure)"
        ];
        config = ''
          ;; Configure eglot server programs
          (add-to-list 'eglot-server-programs '(scala-ts-mode . ("metals")))
          ;; Also support classic scala-mode if tree-sitter mode is unavailable
          (add-to-list 'eglot-server-programs '(scala-mode . ("metals")))
          (add-to-list 'eglot-server-programs '(python-mode . ("basedpyright" "--langserver")))
          (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
          (add-to-list 'eglot-server-programs '(terraform-mode . ("terraform-ls" "serve")))
          (add-to-list 'eglot-server-programs '(haskell-ts-mode . ("haskell-language-server-wrapper" "--lsp")))


          ;; Core Eglot configuration
          (setq eglot-autoshutdown t)
          (setq eglot-sync-connect nil)
          (setq eglot-extend-to-xref t)
          (setq eglot-stay-out-of nil)
          (setq eglot-events-buffer-size 0) ;; Disable events buffer for performance
          (setq eglot-ignored-server-capabilities '(:hoverProvider))

          ;; Track GC tuning per active Eglot buffer to keep interactive
          ;; commands snappy outside of LSP sessions.
          (defvar hm/eglot--managed-buffer-count 0
            "Number of buffers currently managed by Eglot.")
          (defvar hm/eglot--gc-threshold-backup gc-cons-threshold
            "GC threshold value to restore when Eglot releases all buffers.")

          (defun hm/eglot--tune ()
            "Raise GC threshold while Eglot is active and restore when it exits."
            (when (boundp 'eglot-managed-mode)
              (if eglot-managed-mode
                  (progn
                    (when (= hm/eglot--managed-buffer-count 0)
                      (setq hm/eglot--gc-threshold-backup gc-cons-threshold))
                    (setq hm/eglot--managed-buffer-count
                          (1+ hm/eglot--managed-buffer-count))
                    (setq gc-cons-threshold 100000000)
                    (setq-local read-process-output-max (* 1024 1024)))
                (setq hm/eglot--managed-buffer-count
                      (max 0 (1- hm/eglot--managed-buffer-count)))
                (when (= hm/eglot--managed-buffer-count 0)
                  (setq gc-cons-threshold hm/eglot--gc-threshold-backup)))))

          (add-hook 'eglot-managed-mode-hook #'hm/eglot--tune)
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
        defer = true;
        command = [ "dap-mode" "dap-debug" "dap-debug-edit-template" ];
        hook = [
          "(python-mode . dap-mode)"
          "(go-ts-mode . dap-mode)"
          "(scala-ts-mode . dap-mode)"
          "(dap-mode . dap-ui-mode)"
          "(dap-mode . dap-tooltip-mode)"
        ];
        init = ''
          ;; Load DAP on demand; avoid global activation during startup.
          (setq dap-auto-configure-mode t)
        '';
      };

      # AI-powered shell assistance in Emacs
      agent-shell = {
        enable = true;
        package = epkgs: epkgs.agent-shell;
        defer = true;
        command = [ "agent-shell" "agent-shell-mode" ];
        config = ''
          ;; Configure agent-shell
          (setq agent-shell-api-key (getenv "ANTHROPIC_API_KEY"))
        '';
      };

      # Language-specific configurations are now in separate modules
      # See languages/ directory for individual language setups
    };

    home.sessionVariables.EGLOT_BOOTSTRAP_EXEC = "emacs-lsp-booster";
  };
}
