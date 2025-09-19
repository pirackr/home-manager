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

      # Syntax checking (built-in)
      flymake = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in package
        hook = [ "(prog-mode . flymake-mode)" ];
        bind = {
          "C-c ! l" = "flymake-show-buffer-diagnostics";
          "C-c ! n" = "flymake-goto-next-error";
          "C-c ! p" = "flymake-goto-prev-error";
        };
      };

      # Built-in tree-sitter integration (Emacs 29+)
      treesit-auto = {
        enable = true;
        package = epkgs: epkgs.treesit-auto;
        config = ''
          ;; Configure treesit-auto to install grammars for specific languages
          (setq treesit-language-source-alist
                '((haskell "https://github.com/tree-sitter/tree-sitter-haskell")
                  (go "https://github.com/tree-sitter/tree-sitter-go")
                  (yaml "https://github.com/ikatyang/tree-sitter-yaml")
                  (scala "https://github.com/tree-sitter/tree-sitter-scala")))

          ;; Skip automatic tree-sitter grammar installation; install manually when needed to
          ;; avoid blocking startup on large tree-sitter builds.
        '';
        custom = {
          treesit-auto-install = "'prompt";
        };
      };
    };
  };
}
