{ config, pkgs, lib, ... }:

let
  cfg = config.modules.fcitx;
in
{
  options.modules.fcitx = {
    enable = lib.mkEnableOption "Fcitx5 input method editor";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-unikey
      ];
    };

    # Set environment variables for fcitx
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx";
      SDL_IM_MODULE = "fcitx";
    };
  };
}
