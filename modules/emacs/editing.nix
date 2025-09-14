{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Text movement and manipulation
      move-text = {
        enable = true;
        package = epkgs: epkgs.move-text;
        defer = true;
        bind = {
          "M-S-<up>" = "move-text-up";
          "M-S-<down>" = "move-text-down";
        };
      };

      # Project management using built-in project.el
      # Additional configuration for project.el integration
      project = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in package
        config = ''
          ;; Configure project.el settings
          (setq project-switch-commands
                '((project-find-file "Find file")
                  (project-find-regexp "Find regexp")
                  (project-dired "Dired")
                  (magit-project-status "Magit" ?m)
                  (project-eshell "Eshell" ?e)))

          ;; Enable project.el integration with consult
          (with-eval-after-load 'consult
            (setq consult-project-function (lambda (_) (project-root (project-current t)))))
        '';
      };

      # File tree explorer
      treemacs = {
        enable = true;
        package = epkgs: epkgs.treemacs;
        defer = true;
        command = [ "treemacs" "treemacs-select-window" ];
        config = ''
          (require 'treemacs)
        '';
      };

      treemacs-all-the-icons = {
        enable = true;
        package = epkgs: epkgs.treemacs-all-the-icons;
        after = [ "treemacs" ];
        defer = true;
      };

      treemacs-magit = {
        enable = true;
        package = epkgs: epkgs.treemacs-magit;
        after = [ "treemacs" "magit" ];
        defer = true;
      };


      treemacs-icons-dired = {
        enable = true;
        package = epkgs: epkgs.treemacs-icons-dired;
        after = [ "treemacs" ];
        defer = true;
      };

      # Git integration
      magit = {
        enable = true;
        package = epkgs: epkgs.magit;
        defer = true;
        command = [ "magit-status" "magit-log" "magit-diff" "magit-blame" ];
      };

      # GitHub integration
      forge = {
        enable = true;
        package = epkgs: epkgs.forge;
        after = [ "magit" ];
        init = ''
          (setq forge-add-default-sections nil)
          (setq forge-add-default-bindings nil)
        '';
      };

      # Git diff highlighting
      diff-hl = {
        enable = true;
        package = epkgs: epkgs.diff-hl;
        defer = true;
        hook = [
          "(find-file . diff-hl-mode)"
          "(dired-mode . diff-hl-dired-mode)"
          "(magit-post-refresh . diff-hl-magit-post-refresh)"
        ];
      };

      # Org mode and note-taking
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

      # Code formatting
      apheleia = {
        enable = true;
        package = epkgs: epkgs.apheleia;
        defer = true;
        hook = [ "(prog-mode . apheleia-mode)" ];
      };
    };
  };
}