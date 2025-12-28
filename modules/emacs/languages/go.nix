{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Go language support
      go-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in in Emacs 29+
        mode = [
          ''("\\.go\\'" . go-ts-mode)''
        ];
        hook = [
          ''(go-ts-mode . (lambda ()
                             ;; Go uses tabs with an 8-space width; align editor indent accordingly.
                             (setq-local indent-tabs-mode t)
                             (setq-local tab-width 8)
                             (setq-local go-ts-mode-indent-offset 8)))''
        ];
      };

      # Go module support
      go-mod-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in in Emacs 29+
        mode = [
          ''("go\\.mod\\'" . go-mod-ts-mode)''
        ];
      };
    };
  };
}
