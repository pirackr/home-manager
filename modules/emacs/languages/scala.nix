{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    # Provide Scala toolchain on PATH for Eglot/Metals and formatting
    home.packages = with pkgs; [
      metals
      sbt
      jdk
      scalafmt
    ];

    programs.emacs.init.usePackage = {
      # Tree-sitter based Scala major mode
      scala-ts-mode = {
        enable = true;
        # Prefer epkgs.scala-ts-mode; fall back to scala-mode if not present
        package = epkgs: (epkgs.scala-ts-mode or epkgs.scala-mode);
        mode = [
          "\\.scala\\'"
          "\\.sbt\\'"
          "\\.sc\\'"  # Ammonite scripts
        ];
        init = ''
          ;; Ensure scala-ts-mode is used; fallback to scala-mode if not present
          (if (fboundp 'scala-ts-mode)
              (progn
                (add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-ts-mode))
                (add-to-list 'auto-mode-alist '("\\.sbt\\'" . scala-ts-mode))
                (add-to-list 'auto-mode-alist '("\\.sc\\'" . scala-ts-mode)))
            (progn
              (add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode))
              (add-to-list 'auto-mode-alist '("\\.sbt\\'" . scala-mode))
              (add-to-list 'auto-mode-alist '("\\.sc\\'" . scala-mode))
              (add-hook 'scala-mode-hook #'eglot-ensure)))
        '';
        hook = [
          "(scala-ts-mode . eglot-ensure)"
        ];
      };

      java-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in package
        mode = [ "\\.java\\'" ];
        hook = [
          "(java-mode . eglot-ensure)"
        ];
      };

      sbt-mode = {
        enable = true;
        package = epkgs: epkgs.sbt-mode;
        defer = true;
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
    };
  };
}
