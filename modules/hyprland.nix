{ config, pkgs, nixgl, lib, ... }:

let
  cfg = config.modules.hyprland;

  # Define variables
  terminal = "kitty";
  fileManager = "pcmanfm";
  menu = "rofi -show drun";
  runMenu = "rofi -show run";
  windowMenu = "rofi -show window";
  browser = "firefox";
  lock = "hyprlock";

  # Define color variables
  blue = "rgb(89b4fa)";
  base = "rgb(1e1e2e)";

  mainMod = "SUPER";

  # Helper for binds
  mkBind = mods: key: dispatcher: args:
    "${lib.concatStringsSep " " mods}, ${key}, ${dispatcher}, ${args}";
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      default = "firefox";
      description = "Default web browser";
    };

    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "pcmanfm";
      description = "Default file manager";
    };
  };

  config = lib.mkIf cfg.enable {
    # Only enable on Linux systems
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "Hyprland module requires a Linux system";
      }
    ];

    # Required packages
    home.packages = with pkgs; lib.optionals stdenv.isLinux [
      # TODO: extract these out later 
      waybar
      mako
      hyprpaper
      rofi-wayland
      pcmanfm
      firefox
      grim
      slurp
      brightnessctl
      playerctl
      pulseaudio
      adwaita-icon-theme
      hyprlock
      # TODO Add this just because we don't want it for MacOS at first 
      gemini-cli
    ];

    xdg.configFile."hypr/hyprlock.conf".text = ''
      # Catppuccin Macchiato colors
      $rosewater = 0xf4dbd6
      $flamingo = 0xf0c6c6
      $pink = 0xf5bde6
      $mauve = 0xc6a0f6
      $red = 0xed8796
      $maroon = 0xee99a0
      $peach = 0xf5a97f
      $yellow = 0xeed49f
      $green = 0xa6da95
      $teal = 0x8bd5ca
      $sky = 0x91d7e3
      $sapphire = 0x7dc4e4
      $blue = 0x8aadf4
      $lavender = 0xb7bdf8
      $text = 0xcad3f5
      $subtext1 = 0xb8c0e0
      $subtext0 = 0xa5adce
      $overlay2 = 0x939ab7
      $overlay1 = 0x8087a2
      $overlay0 = 0x6e738d
      $surface2 = 0x5b6078
      $surface1 = 0x494d64
      $surface0 = 0x363a4f
      $base = 0x24273a
      $mantle = 0x1e2030
      $crust = 0x181926

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
      preload = ~/wallpapers/forrest.png
      wallpaper = HDMI-A-1, ~/wallpapers/forrest.png
      splash = false
      ipc = off
    '';

    # Enable hyprland
    wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.hyprland);
      # package = null; # Use system package

      # Use extraConfig for complex settings
      extraConfig = ''
        # Auto-start applications
        exec-once=${pkgs.waybar}/bin/waybar & ${pkgs.mako}/bin/mako & ${pkgs.hyprpaper}/bin/hyprpaper

        # Per-device config
        device {
            name = epic-mouse-v1
            sensitivity = -0.5
        }

        # Window rules v2
        windowrulev2 = suppressevent maximize, class:.*

        # Volume and Media Control Binds
        bind = , XF86AudioRaiseVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +10%
        bind = , XF86AudioLowerVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -10%
        bind = , XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
        bind = , XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause
        bind = , XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause
        bind = , XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next
        bind = , XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous

        # Screen brightness binds
        bind = , XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s +5%
        bind = , XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 5%-

        # Screenshot binds
        bind = ,Print, exec, ${pkgs.grim}/bin/grim $(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png')
        bind = Shift,Print, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)"

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = ${mainMod}, mouse:272, movewindow
        bindm = ${mainMod}, mouse:273, resizewindow
      '';

      settings = {
        # Monitors
        monitor = [
          ",preferred,auto,1"
        ];

        # Environment Variables
        env = [
          "HYPRCURSOR_THEME,Adwaita"
          "HYPRCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct"
          "QT_QPA_PLATFORM,wayland"
          "MOZ_ENABLE_WAYLAND,1"
        ];

        # Input Settings
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
          };
        };

        # General Settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = blue;
          "col.inactive_border" = base;

          layout = "dwindle";
          allow_tearing = false;
        };

        # Decoration Settings
        decoration = {
          rounding = 4;
          blur = {
            enabled = false;
            size = 7;
            passes = 3;
          };
        };

        # Animations Settings
        animations = {
          enabled = true;
          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.05"
          ];
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Dwindle Layout Settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Master Layout Settings
        master = {
          new_status = "master";
        };

        # Gestures Settings
        gestures = {
          workspace_swipe = true;
        };

        # Misc Settings
        misc = {
          force_default_wallpaper = 0;
        };

        # Binds
        bind = [
          # Application Launchers
          (mkBind [ mainMod ] "RETURN" "exec" cfg.terminal)
          (mkBind [ mainMod "Shift" ] "E" "exec" cfg.fileManager)
          (mkBind [ mainMod "Shift" ] "B" "exec" cfg.browser)
          (mkBind [ mainMod ] "D" "exec" menu)
          (mkBind [ "alt" ] "space" "exec" runMenu)
          (mkBind [ mainMod "SHIFT" ] "X" "exec" lock)

          # Window Management
          (mkBind [ mainMod "Shift" ] "Q" "killactive" "")
          (mkBind [ mainMod ] "M" "exit" "")
          (mkBind [ mainMod ] "V" "togglefloating" "")
          (mkBind [ mainMod ] "F" "fullscreen" "")
          (mkBind [ mainMod ] "P" "pseudo" "")
          (mkBind [ mainMod "SHIFT" ] "J" "togglesplit" "")

          # Move focus (vim keys)
          (mkBind [ mainMod ] "h" "movefocus" "l")
          (mkBind [ mainMod ] "l" "movefocus" "r")
          (mkBind [ mainMod ] "k" "movefocus" "u")
          (mkBind [ mainMod ] "j" "movefocus" "d")

          # Move focus (arrow keys)
          (mkBind [ mainMod ] "left" "movefocus" "l")
          (mkBind [ mainMod ] "right" "movefocus" "r")
          (mkBind [ mainMod ] "up" "movefocus" "u")
          (mkBind [ mainMod ] "down" "movefocus" "d")

          # Resize Windows
          (mkBind [ mainMod "SHIFT" ] "right" "resizeactive" "20 0")
          (mkBind [ mainMod "SHIFT" ] "left" "resizeactive" "-20 0")
          (mkBind [ mainMod "SHIFT" ] "up" "resizeactive" "0 -20")
          (mkBind [ mainMod "SHIFT" ] "down" "resizeactive" "0 20")

          # Switch workspaces
          (mkBind [ mainMod ] "1" "workspace" "1")
          (mkBind [ mainMod ] "2" "workspace" "2")
          (mkBind [ mainMod ] "3" "workspace" "3")
          (mkBind [ mainMod ] "4" "workspace" "4")
          (mkBind [ mainMod ] "5" "workspace" "5")
          (mkBind [ mainMod ] "6" "workspace" "6")
          (mkBind [ mainMod ] "7" "workspace" "7")
          (mkBind [ mainMod ] "8" "workspace" "8")
          (mkBind [ mainMod ] "9" "workspace" "9")
          (mkBind [ mainMod ] "0" "workspace" "10")

          # Move active window to a workspace
          (mkBind [ mainMod "SHIFT" ] "1" "movetoworkspace" "1")
          (mkBind [ mainMod "SHIFT" ] "2" "movetoworkspace" "2")
          (mkBind [ mainMod "SHIFT" ] "3" "movetoworkspace" "3")
          (mkBind [ mainMod "SHIFT" ] "4" "movetoworkspace" "4")
          (mkBind [ mainMod "SHIFT" ] "5" "movetoworkspace" "5")
          (mkBind [ mainMod "SHIFT" ] "6" "movetoworkspace" "6")
          (mkBind [ mainMod "SHIFT" ] "7" "movetoworkspace" "7")
          (mkBind [ mainMod "SHIFT" ] "8" "movetoworkspace" "8")
          (mkBind [ mainMod "SHIFT" ] "9" "movetoworkspace" "9")
          (mkBind [ mainMod "SHIFT" ] "0" "movetoworkspace" "10")

          # Cycle through workspaces
          (mkBind [ mainMod ] "TAB" "workspace" "e+1")
          (mkBind [ mainMod "SHIFT" ] "TAB" "workspace" "e-1")

          # Special workspace (scratchpad)
          (mkBind [ mainMod ] "S" "togglespecialworkspace" "magic")
          (mkBind [ mainMod "SHIFT" ] "S" "movetoworkspace" "special:magic")

          # Scroll through existing workspaces with mainMod + scroll
          (mkBind [ mainMod ] "mouse_down" "workspace" "e+1")
          (mkBind [ mainMod ] "mouse_up" "workspace" "e-1")
        ];
      };
    };

    # Hyprland cursor theme
    home.pointerCursor = lib.mkIf pkgs.stdenv.isLinux {
      name = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
      gtk.enable = true;
    };
  };
}
