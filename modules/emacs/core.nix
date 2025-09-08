{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Built-in Emacs packages and basic functionality
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

      # Path synchronization from shell
      exec-path-from-shell = {
        enable = true;
        package = epkgs: epkgs.exec-path-from-shell;
        config = ''
          (exec-path-from-shell-initialize)
        '';
      };

      # Auto-save and session management
      super-save = {
        enable = true;
        package = epkgs: epkgs.super-save;
        config = ''
          (super-save-mode +1)
        '';
      };

      # Undo system
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

      editorconfig = {
        enable = true;
        package = epkgs: epkgs.editorconfig;
      };

      # Spell checking
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

      # Syntax checking
      flycheck = {
        enable = true;
        package = epkgs: epkgs.flycheck;
        defer = true;
        hook = [ "(prog-mode . flycheck-mode)" ];
      };

      # Tree-sitter for better syntax highlighting
      tree-sitter = {
        enable = true;
        package = epkgs: epkgs.tree-sitter;
        defer = true;
        hook = [ "(prog-mode . tree-sitter-mode)" ];
        config = ''
          (require 'tree-sitter)
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

      # Modern tree-sitter integration
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
    };
  };
}
