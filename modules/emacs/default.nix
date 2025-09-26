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
          # - core.nix: dired, exec-path-from-shell, super-save, undo-fu, tree-sitter, jinx, flymake, which-key, editorconfig
          # - completion.nix: vertico, consult, company, yasnippet, anzu, fzf
          # - editing.nix: move-text, treemacs, magit, forge, diff-hl, org-mode, apheleia
          # - development.nix: eglot, eglot-booster, dap-mode, scala-ts-mode, sbt-mode, go-ts-mode, poetry, yapfify, posframe, nix-mode, hcl-mode, terraform-mode
          # - themes.nix: catppuccin-theme, doom-modeline, nerd-icons packages
        };

        # Basic configuration in prelude (read from file)
        prelude = builtins.readFile ./prelude.el;

        # Additional global configuration
        earlyInit = ''
          ;; Performance optimizations
          (setq gc-cons-threshold 100000000)  ;; 100mb during startup
          (setq gc-cons-percentage 0.6)
          (setq read-process-output-max (* 1024 1024))  ;; 1mb

          ;; Defer file-name handlers during startup for faster I/O (restored after init)
          (defvar hm--file-name-handler-alist file-name-handler-alist)
          (setq file-name-handler-alist nil)
          (add-hook 'emacs-startup-hook
                    (lambda ()
                      (setq file-name-handler-alist hm--file-name-handler-alist)
                      (makunbound 'hm--file-name-handler-alist)))

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

          ;; Report startup time and garbage collection count once Emacs finishes booting.
          (add-hook 'emacs-startup-hook
                    (lambda ()
                      (message "[perf] Emacs ready in %.2fs (GCs: %d)"
                               (float-time (time-subtract (current-time) before-init-time))
                               gcs-done)))

          ;; Lightweight command duration logger for interactive commands.
          (defgroup hm-performance nil
            "Home Manager performance helpers."
            :group 'convenience)

          (defcustom hm-command-timer-threshold 0.20
            "Minimum number of seconds a command must take before it is logged."
            :type 'number
            :group 'hm-performance)

          (defvar hm--command-timer-start nil
            "Internal timestamp for the last command start time.")

          (defvar hm--command-timer-last-command nil
            "Internal reference to the command currently being timed.")

          (defun hm--command-timer-pre ()
            (setq hm--command-timer-start (current-time))
            (setq hm--command-timer-last-command this-command))

          (defun hm--command-timer-post ()
            (when (and hm--command-timer-start hm--command-timer-last-command)
              (let* ((end (current-time))
                     (elapsed (float-time (time-subtract end hm--command-timer-start))))
                (when (> elapsed hm-command-timer-threshold)
                  (message "[perf] %s completed in %.3fs"
                           hm--command-timer-last-command
                           elapsed)))
              (setq hm--command-timer-start nil)
              (setq hm--command-timer-last-command nil)))

          (define-minor-mode hm-command-timer-mode
            "Global minor mode to report slow interactive commands."
            :global t
            (if hm-command-timer-mode
                (progn
                  (remove-hook 'pre-command-hook #'hm--command-timer-pre)
                  (remove-hook 'post-command-hook #'hm--command-timer-post)
                  (add-hook 'pre-command-hook #'hm--command-timer-pre)
                  (add-hook 'post-command-hook #'hm--command-timer-post))
              (remove-hook 'pre-command-hook #'hm--command-timer-pre)
              (remove-hook 'post-command-hook #'hm--command-timer-post)))

          (hm-command-timer-mode 1)
        '';
      };
    };
  };
}
