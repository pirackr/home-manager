{ config, pkgs, lib, ... }:

{
  options.modules.ui.hyprlock = {
    enable = lib.mkEnableOption "Hyprlock screen locker with Catppuccin theme";
  };

  config = lib.mkIf config.modules.ui.hyprlock.enable {
    home.packages = with pkgs; [
      hyprlock
    ];

    xdg.configFile."hypr/hyprlock.conf".text = ''
      # Catppuccin Frappe colors
      $rosewater = 0xf2d5cf
      $flamingo = 0xeebebe
      $pink = 0xf4b8e4
      $mauve = 0xca9ee6
      $red = 0xe78284
      $maroon = 0xea999c
      $peach = 0xef9f76
      $yellow = 0xe5c890
      $green = 0xa6d189
      $teal = 0x81c8be
      $sky = 0x99d1db
      $sapphire = 0x85c1dc
      $blue = 0x8caaee
      $lavender = 0xbabbf1
      $text = 0xc6d0f5
      $subtext1 = 0xb5bfe2
      $subtext0 = 0xa5adce
      $overlay2 = 0x949cbb
      $overlay1 = 0x838ba7
      $overlay0 = 0x737994
      $surface2 = 0x626880
      $surface1 = 0x51576d
      $surface0 = 0x414559
      $base = 0x303446
      $mantle = 0x292c3c
      $crust = 0x232634

      $accent = $mauve
      $font = JetBrainsMono Nerd Font

      # GENERAL
      general {
        disable_loading_bar = true
        hide_cursor = true
      }

      # BACKGROUND
      background {
        monitor =
        path = $HOME/.config/background
        blur_passes = 0
        color = $base
      }

      # LAYOUT
      label {
        monitor =
        text = Layout: $LAYOUT
        color = $text
        font_size = 25
        font_family = $font
        position = 30, -30
        halign = left
        valign = top
      }

      # TIME
      label {
        monitor =
        text = $TIME
        color = $text
        font_size = 90
        font_family = $font
        position = -30, 0
        halign = right
        valign = top
      }

      # DATE
      label {
        monitor =
        text = cmd[update:43200000] date +"%A, %d %B %Y"
        color = $text
        font_size = 25
        font_family = $font
        position = -30, -150
        halign = right
        valign = top
      }

      # USER AVATAR
      image {
        monitor =
        path = $HOME/.face
        size = 100
        border_color = $accent
        position = 0, 75
        halign = center
        valign = center
      }

      # INPUT FIELD
      input-field {
        monitor =
        size = 300, 60
        outline_thickness = 4
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = $accent
        inner_color = $surface0
        font_color = $text
        fade_on_empty = false
        placeholder_text = <span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>
        hide_input = false
        check_color = $accent
        fail_color = $red
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        capslock_color = $yellow
        position = 0, -47
        halign = center
        valign = center
      }
    '';

    xdg.configFile."hypr/hyprpaper.conf".text = ''
      splash = false
      ipc = on 
    '';
  };
}
