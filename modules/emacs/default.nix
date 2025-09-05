{ config, lib, pkgs, ... }:

{
  imports = [
    ./emacs-init.nix
    ./evil.nix
    ./haskell.nix
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
          doom-modeline = {
            enable = true;
            package = epkgs: epkgs.doom-modeline;
            config = ''
              (doom-modeline-mode 1)
            '';
          };

          dired = {
            enable = true;
            package = epkgs: epkgs.emacs; # Built-in package
            config = ''
              ;; dired - reuse current buffer by pressing 'a'
              (put 'dired-find-alternate-file 'disabled nil)

              ;; always delete and copy recursively
              (setq dired-recursive-deletes 'always)
              (setq dired-recursive-copies 'always)

              ;; if there is a dired buffer displayed in the next window, use its
              ;; current subdir, instead of the current subdir of this dired buffer
              (setq dired-dwim-target t)

              ;; enable some really cool extensions like C-x C-j(dired-jump)
              (require 'dired-x)
            '';
          };

          # Displays current match and total matches information in the mode-line in various search modes.
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

          exec-path-from-shell = {
            enable = true;
            package = epkgs: epkgs.exec-path-from-shell;
            config = ''
              (exec-path-from-shell-initialize)
            '';
          };

          move-text = {
            enable = true;
            package = epkgs: epkgs.move-text;
            bind = {
              "M-S-<up>" = "move-text-up";
              "M-S-<down>" = "move-text-down";
            };
          };

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

          forge = {
            enable = true;
            package = epkgs: epkgs.forge;
            after = [ "magit" ];
            init = ''
              (setq forge-add-default-sections nil)
              (setq forge-add-default-bindings nil)
            '';
          };

          all-the-icons-nerd-fonts = {
            enable = true;
            package = epkgs: epkgs.all-the-icons-nerd-fonts;
          };

          all-the-icons-completion = {
            enable = true;
            package = epkgs: epkgs.all-the-icons-completion;
            after = [ "marginalia" "all-the-icons" ];
            hook = [ "(marginalia-mode . all-the-icons-completion-marginalia-setup)" ];
            init = ''
              (all-the-icons-completion-mode)
            '';
          };

          treesit-auto = {
            enable = true;
            package = epkgs: epkgs.treesit-auto;
            config = ''
              (treesit-auto-add-to-auto-mode-alist 'all)
              (global-treesit-auto-mode)
            '';
            custom = {
              treesit-auto-install = "'prompt";
            };
          };

          treemacs = {
            enable = true;
            package = epkgs: epkgs.treemacs;
            config = ''
              (require 'treemacs)
            '';
          };

          treemacs-all-the-icons = {
            enable = true;
            package = epkgs: epkgs.treemacs-all-the-icons;
            after = [ "treemacs" ];
          };

          treemacs-magit = {
            enable = true;
            package = epkgs: epkgs.treemacs-magit;
            after = [ "treemacs" ];
          };

          treemacs-projectile = {
            enable = true;
            package = epkgs: epkgs.treemacs-projectile;
            after = [ "treemacs" ];
          };

          treemacs-icons-dired = {
            enable = true;
            package = epkgs: epkgs.treemacs-icons-dired;
            after = [ "treemacs" ];
          };

          consult = {
            enable = true;
            package = epkgs: epkgs.consult;
          };

          company = {
            enable = true;
            package = epkgs: epkgs.company;
            config = ''
              ;; (add-to-list 'company-backends 'company-nixos-options)
              (global-company-mode)
            '';
          };

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

          yasnippet = {
            enable = true;
            package = epkgs: epkgs.yasnippet;
            config = ''
              (yas-global-mode 1)
              ;; Enable yasnippet integration with eglot
              (add-hook 'eglot-managed-mode-hook 'yas-minor-mode)
            '';
          };

          go-ts-mode = {
            enable = true;
            package = epkgs: epkgs.emacs; # Built-in package in newer Emacs
          };

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


          posframe = {
            enable = true;
            package = epkgs: epkgs.posframe;
          };

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

          # yaml-ts-mode = {
          #   enable = true;
          #   package = epkgs: epkgs.yaml-ts-mode;
          # };

          apheleia = {
            enable = true;
            package = epkgs: epkgs.apheleia;
            init = ''
              (require 'apheleia)
            '';
          };

          flyspell = {
            enable = true;
            package = epkgs: epkgs.emacs; # Built-in package
            config = ''
              (when (eq system-type 'windows-nt)
                (add-to-list 'exec-path "C:/Program Files (x86)/Aspell/bin/"))
              (setq ispell-program-name "aspell" ; use aspell instead of ispell
                    ispell-extra-args '("--sug-mode=ultra"))
              (add-hook 'text-mode-hook #'flyspell-mode)
              (add-hook 'prog-mode-hook #'flyspell-prog-mode)
            '';
          };

          flycheck = {
            enable = true;
            package = epkgs: epkgs.flycheck;
            config = ''
              (add-hook 'after-init-hook #'global-flycheck-mode)
            '';
          };

          diff-hl = {
            enable = true;
            package = epkgs: epkgs.diff-hl;
            config = ''
              (global-diff-hl-mode +1)
              (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
              (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
            '';
          };

          super-save = {
            enable = true;
            package = epkgs: epkgs.super-save;
            config = ''
              (super-save-mode +1)
            '';
          };

          projectile = {
            enable = true;
            package = epkgs: epkgs.projectile;
            config = ''
              (projectile-mode +1)
            '';
          };

          fzf = {
            enable = true;
            package = epkgs: epkgs.fzf;
          };

          magit = {
            enable = true;
            package = epkgs: epkgs.magit;
          };

          undo-fu = {
            enable = true;
            package = epkgs: epkgs.undo-fu;
          };

          undo-fu-session = {
            enable = true;
            package = epkgs: epkgs.undo-fu-session;
            config = ''
              (global-undo-fu-session-mode)
            '';
          };

          tree-sitter = {
            enable = true;
            package = epkgs: epkgs.tree-sitter;
            config = ''
              (require 'tree-sitter)
              (global-tree-sitter-mode)
            '';
          };

          tree-sitter-langs = {
            enable = true;
            package = epkgs: epkgs.tree-sitter-langs;
            after = [ "tree-sitter" ];
            config = ''
              (require 'tree-sitter-langs)
            '';
          };

          catppuccin-theme = {
            enable = true;
            package = epkgs: epkgs.catppuccin-theme;
            config = ''
              (load-theme 'catppuccin :no-confirm)
            '';
          };


          nix-mode = {
            enable = true;
            package = epkgs: epkgs.nix-mode;
          };

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

          org = {
            enable = true;
            package = epkgs: epkgs.org;
            config = ''
              (setq evil-want-C-i-jump nil)

              (setq org-todo-keywords '
                    ((sequence "TODO(t)" "WIP(w)" "BLOCK(b)"
                               "|"
                               "DONE(d/!)" "KILL(k/!)")))

              (setq org-todo-keyword-faces
                '(("TODO" . (:foreground "#ff39a3" :weight bold))
                 ("WIP" . "#E35DBF")
                 ("KILL" . (:foreground "white" :background "#4d4d4d" :weight bold))
                 ("DONE" . "#008080")))
              (setq org-directory "/ssh:www-data@silly-wombat.pirackr.xyz:/org")
              (setq org-agenda-files (list org-directory))
              (setq org-refile-targets  '((org-agenda-files :maxlevel . 2)))
              (setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
              (setq org-refile-use-outline-path t)
              (setq org-roam-directory "/ssh:www-data@silly-wombat.pirackr.xyz:/org/notes")

              (setq org-agenda-custom-commands `((" " "Agenda"
                                                ((agenda "Today"
                                                         ((org-agenda-overriding-header "Today")
                                                          (org-agenda-span 'day)
                                                          (org-agenda-start-day "-0d")
                                                          (org-agenda-skip-deadline-prewarning-if-scheduled t))
                                                         )
                                                 (todo "WIP"
                                                       ((org-agenda-overriding-header "WIP")))
                                                 (agenda "SOON"
                                                         ((org-agenda-overriding-header "Next 5 days")
                                                          (org-agenda-start-day "+1d")
                                                          (org-agenda-span 5)
                                                          ))
                                                 ))))
            '';
          };

          org-roam = {
            enable = true;
            package = epkgs: epkgs.org-roam;
            after = [ "org" ];
          };

          org-bullets = {
            enable = true;
            package = epkgs: epkgs.org-bullets;
            after = [ "org" ];
            hook = [ "(org-mode . org-bullets-mode)" ];
          };

          # Additional packages for global configuration
          which-key = {
            enable = true;
            package = epkgs: epkgs.which-key;
          };

          editorconfig = {
            enable = true;
            package = epkgs: epkgs.editorconfig;
          };
        };

        # Basic configuration in prelude (read from file)
        prelude = builtins.readFile ./prelude.el;

        # Additional global configuration
        earlyInit = ''
          ;; Additional early initialization
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
