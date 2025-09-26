{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # YAML support
      yaml-ts-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in in Emacs 29+
        mode = [ ''("\\.ya?ml\\'" . yaml-ts-mode)'' ];
        hook = [
          "(yaml-ts-mode . eglot-ensure)"
        ];
      };
    };
  };
}
