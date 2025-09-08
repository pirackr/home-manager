{ config, lib, pkgs, ... }:

{
  imports = [
    ./emacs-init.nix
    ./evil.nix
    ./haskell.nix
    ./core.nix
    ./completion.nix
    ./editing.nix
    ./development.nix
    ./themes.nix
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

        # Core usePackage configuration remains empty as all packages are now in focused modules
        usePackage = {
          # All package configurations moved to focused modules:
          # - core.nix: dired, exec-path-from-shell, super-save, undo-fu, tree-sitter, flyspell, flycheck, which-key, editorconfig
          # - completion.nix: vertico, consult, company, yasnippet, anzu, fzf
          # - editing.nix: move-text, projectile, treemacs, magit, forge, diff-hl, org-mode, apheleia
          # - development.nix: eglot, eglot-booster, dap-mode, scala-ts-mode, sbt-mode, go-ts-mode, poetry, yapfify, posframe, nix-mode, hcl-mode, terraform-mode
          # - themes.nix: catppuccin-theme, doom-modeline, all-the-icons packages
        };

        # Basic configuration in prelude (read from file)
        prelude = builtins.readFile ./prelude.el;

        # Additional global configuration
        earlyInit = ''
          ;; Performance optimizations
          (setq gc-cons-threshold 100000000)  ;; 100mb during startup
          (setq gc-cons-percentage 0.6)
          (setq read-process-output-max (* 1024 1024))  ;; 1mb

          ;; Native compilation settings
          (when (fboundp 'native-comp-available-p)
            (setq native-comp-async-report-warnings-errors 'silent)
            (setq native-comp-jit-compilation t)
            (setq native-comp-deferred-compilation t)
            (setq native-comp-speed 2)
            (setq native-comp-debug 0)
            ;; Set native-comp cache directory to avoid permission issues
            (when (fboundp 'startup-redirect-eln-cache)
              (startup-redirect-eln-cache
               (convert-standard-filename
                (expand-file-name "var/eln-cache/" user-emacs-directory)))))
        '';

        postlude = ''
          ;; Global settings from init.el
          (setq treesit-language-source-alist
           '((bash "https://github.com/tree-sitter/tree-sitter-bash")
             (cmake "https://github.com/uyha/tree-sitter-cmake")
             (css "https://github.com/tree-sitter/tree-sitter-css")
             (elisp "https://github.com/Wilfred/tree-sitter-elisp")
             (go "https://github.com/tree-sitter/tree-sitter-go")
             (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
             (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
             (haskell "https://github.com/tree-sitter/tree-sitter-haskell")
             (html "https://github.com/tree-sitter/tree-sitter-html")
             (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
             (json "https://github.com/tree-sitter/tree-sitter-json")
             (make "https://github.com/alemuller/tree-sitter-make")
             (markdown "https://github.com/ikatyang/tree-sitter-markdown")
             (python "https://github.com/tree-sitter/tree-sitter-python")
             (toml "https://github.com/tree-sitter/tree-sitter-toml")
             (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
             (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
             (scala "https://github.com/tree-sitter/tree-sitter-scala")
             (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

          ;; Additional global settings
          (setq backup-directory-alist `(("." . "~/.emacs.d/saves")))

          ;; Native compilation information
          (when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
            (message "Native compilation is available")
            (setq comp-deferred-compilation t))

          ;; Reset garbage collection after startup
          (setq gc-cons-threshold 16777216)  ;; Reset to 16mb
          (setq gc-cons-percentage 0.1)

          ;; Enable which-key and editorconfig (using built-in packages)
          (which-key-mode +1)
          (editorconfig-mode 1)

          ;; Require magit
          (require 'magit)
        '';
      };
    };
  };
}
