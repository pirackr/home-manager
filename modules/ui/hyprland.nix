{ config, pkgs, nixgl, lib, ... }:

let
  cfg = config.modules.ui.hyprland;

  # Define variables
  terminal = cfg.terminal;
  fileManager = cfg.fileManager;
  browser = cfg.browser;
  menu = "rofi -show drun";
  runMenu = "rofi -show run";
  windowMenu = "rofi -show window";
  lock = "hyprlock";

  # Define color variables - Catppuccin Frappe
  rosewater = "rgb(f2d5cf)";
  flamingo = "rgb(eebebe)";
  pink = "rgb(f4b8e4)";
  mauve = "rgb(ca9ee6)";
  red = "rgb(e78284)";
  maroon = "rgb(ea999c)";
  peach = "rgb(ef9f76)";
  yellow = "rgb(e5c890)";
  green = "rgb(a6d189)";
  teal = "rgb(81c8be)";
  sky = "rgb(99d1db)";
  sapphire = "rgb(85c1dc)";
  blue = "rgb(8caaee)";
  lavender = "rgb(babbf1)";
  text = "rgb(c6d0f5)";
  subtext1 = "rgb(b5bfe2)";
  subtext0 = "rgb(a5adce)";
  overlay2 = "rgb(949cbb)";
  overlay1 = "rgb(838ba7)";
  overlay0 = "rgb(737994)";
  surface2 = "rgb(626880)";
  surface1 = "rgb(51576d)";
  surface0 = "rgb(414559)";
  base = "rgb(303446)";
  mantle = "rgb(292c3c)";
  crust = "rgb(232634)";

  mainMod = "SUPER";

  # Helper for binds
  mkBind = mods: key: dispatcher: args:
    "${lib.concatStringsSep " " mods}, ${key}, ${dispatcher}, ${args}";
in
{
  options.modules.ui.hyprland = {
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
        message = "Hyprland is only supported on Linux";
      }
    ];

    # Required packages
    home.packages = with pkgs; [
      playerctl
      brightnessctl
      grim
      slurp
      adwaita-icon-theme
      hyprpaper
      hyprlock
    ];

    # Enable hyprland
    wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.hyprland);
      # package = null; # Use system package

      # Use extraConfig for complex settings
      extraConfig = ''
        # Auto-start applications
        exec-once=${pkgs.waybar}/bin/waybar -c ~/.config/waybar/config.json -s ~/.config/waybar/style.css & ${pkgs.mako}/bin/mako & ${pkgs.hyprpaper}/bin/hyprpaper

        # Per-device config
        device {
            name = epic-mouse-v1
            sensitivity = -0.5
        }

        # Window rules v2
        windowrulev2 = suppressevent maximize, class:.*

        # Volume and Media Control Binds (using wpctl for PipeWire)
        bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
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
          "col.active_border" = "${mauve} ${pink} 45deg";
          "col.inactive_border" = surface0;

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

        # Gestures Settings (Hyprland 0.51+ syntax)
        gesture = [
          "3, horizontal, workspace"
        ];

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
