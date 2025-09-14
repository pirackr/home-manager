{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Python development
      python-mode = {
        enable = true;
        package = epkgs: epkgs.emacs; # Built-in package
        mode = [ "\\.py\\'" ];
        hook = [
          "(python-mode . eglot-ensure)"
        ];
      };

      poetry = {
        enable = true;
        package = epkgs: epkgs.poetry;
        defer = true;
      };
    };
  };
}