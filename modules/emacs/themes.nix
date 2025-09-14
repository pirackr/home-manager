{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Color theme
      catppuccin-theme = {
        enable = true;
        package = epkgs: epkgs.catppuccin-theme;
        config = ''
          (load-theme 'catppuccin :no-confirm)
        '';
      };

      # Modeline
      doom-modeline = {
        enable = true;
        package = epkgs: epkgs.doom-modeline;
        config = ''
          (doom-modeline-mode 1)
        '';
      };

      # Icons
      all-the-icons = {
        enable = true;
        package = epkgs: epkgs.all-the-icons;
        defer = true;
      };


      all-the-icons-completion = {
        enable = true;
        package = epkgs: epkgs.all-the-icons-completion;
        after = [ "marginalia" "all-the-icons" ];
        hook = [ "(marginalia-mode . all-the-icons-completion-marginalia-setup)" ];
        init = ''
          (all-the-icons-completion-mode)
        '';
      };
    };
  };
}