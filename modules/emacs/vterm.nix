{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    # vterm requires cmake and libvterm to compile the module
    home.packages = [
      pkgs.cmake
      pkgs.libvterm
    ];

    programs.emacs.init.usePackage = {
      vterm = {
        enable = true;
        package = epkgs: epkgs.vterm;
        config = ''
          (setq vterm-max-scrollback 10000)
          (setq vterm-buffer-name-string "vterm %s")
        '';
      };
    };
  };
}
