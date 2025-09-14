{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Language modes - using built-in treesit modes
      scala-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in in Emacs 29+
        mode = [ "\\.scala\\'" ];
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