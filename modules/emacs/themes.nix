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
      nerd-icons = {
        enable = true;
        package = epkgs: epkgs.nerd-icons;
        defer = true;
      };


      nerd-icons-completion = {
        enable = true;
        package = epkgs: epkgs.nerd-icons-completion;
        after = [ "marginalia" "nerd-icons" ];
        hook = [ "(marginalia-mode . nerd-icons-completion-marginalia-setup)" ];
        init = ''
          (nerd-icons-completion-mode)
        '';
      };
    };
  };
}