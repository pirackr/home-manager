{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Go language support
      go-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in in Emacs 29+
        mode = [ "\\.go\\'" ];
        hook = [
          "(go-ts-mode . eglot-ensure)"
        ];
      };

      # Go module support
      go-mod-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in in Emacs 29+
        mode = [ "go\\.mod\\'" ];
      };
    };
  };
}