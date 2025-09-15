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

  # Define color variables - Catppuccin Frappe
  blue = "rgb(8caaee)";
  base = "rgb(303446)";

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
      rofi
      pcmanfm
      firefox
      grim
      slurp
      brightnessctl
      playerctl
      pwvucontrol
      adwaita-icon-theme
      hyprlock
      # TODO Add this just because we don't want it for MacOS at first
      gemini-cli
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
      preload = ~/wallpapers/pugs.jpg
      wallpaper = HDMI-A-1, ~/wallpapers/pugs.jpg
      splash = false
      ipc = off
    '';

    # Waybar configuration for Hyprland
    xdg.configFile."waybar/config.json".text = builtins.toJSON {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [ "hyprland/workspaces" "hyprland/mode" "hyprland/scratchpad" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "battery" "clock" "tray" ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        warp-on-scroll = false;
        format = "{id}";
        show-special = false;
        on-click = "activate";
        sort-by-number = true;
      };

      "hyprland/mode" = {
        format = "<span style=\"italic\">{}</span>";
      };

      "hyprland/scratchpad" = {
        format = "🗃️ {count}";
        show-empty = false;
        tooltip = true;
        tooltip-format = "{app}: {title}";
      };

      "hyprland/window" = {
        format = "{}";
        max-length = 50;
        separate-outputs = true;
      };

      tray = {
        spacing = 10;
      };

      clock = {
        format = "🕐 {:%H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = "📅 {:%Y-%m-%d}";
      };

      cpu = {
        format = "🖥️ {usage}%";
        tooltip = false;
      };

      memory = {
        format = "🧠 {}%";
      };

      temperature = {
        critical-threshold = 80;
        format = "🌡️ {temperatureC}°C";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "🔋 {capacity}%";
        format-charging = "🔌 {capacity}%";
        format-plugged = "🔌 {capacity}%";
        format-alt = "🔋 {time}";
      };

      network = {
        format-wifi = "📶 {essid} ({signalStrength}%)";
        format-ethernet = "🔗 {ipaddr}/{cidr}";
        tooltip-format = "{ifname} via {gwaddr}";
        format-linked = "🔗 {ifname} (No IP)";
        format-disconnected = "📶 Disconnected";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "🔊 {volume}% {format_source}";
        format-bluetooth = "🎧 {volume}% {format_source}";
        format-bluetooth-muted = "🎧 🔇 {format_source}";
        format-muted = "🔇 {format_source}";
        format-source = "🎤 {volume}%";
        format-source-muted = "🎤 🔇";
        on-click = "pwvucontrol";
      };
    };

    # Rofi configuration with Catppuccin theme
    xdg.configFile."rofi/config.rasi".text = ''
      configuration {
        modi: "drun,run,window";
        show-icons: true;
        terminal: "kitty";
        drun-display-format: "{icon} {name}";
        location: 0;
        disable-history: false;
        hide-scrollbar: true;
        display-drun: "   Apps ";
        display-run: "   Run ";
        display-window: " 﩯  Window";
        display-Network: " 󰤨  Network";
        sidebar-mode: true;
        font: "FiraCode Nerd Font 12";
      }

      @theme "catppuccin-frappe"
    '';

    # Rofi theme file with Catppuccin Frappe colors
    xdg.configFile."rofi/catppuccin-frappe.rasi".text = ''
      /* Catppuccin Frappe Colors */
      * {
        rosewater: #f2d5cf;
        flamingo: #eebebe;
        pink: #f4b8e4;
        mauve: #ca9ee6;
        red: #e78284;
        maroon: #ea999c;
        peach: #ef9f76;
        yellow: #e5c890;
        green: #a6d189;
        teal: #81c8be;
        sky: #99d1db;
        sapphire: #85c1dc;
        blue: #8caaee;
        lavender: #babbf1;
        text: #c6d0f5;
        subtext1: #b5bfe2;
        subtext0: #a5adce;
        overlay2: #949cbb;
        overlay1: #838ba7;
        overlay0: #737994;
        surface2: #626880;
        surface1: #51576d;
        surface0: #414559;
        base: #303446;
        mantle: #292c3c;
        crust: #232634;

        /* Global colors */
        background-color: transparent;
        text-color: @text;
        font: "FiraCode Nerd Font 12";
      }

      window {
        background-color: @base;
        border: 2px solid;
        border-color: @mauve;
        border-radius: 8px;
        width: 600px;
        location: center;
        anchor: center;
      }

      mainbox {
        background-color: transparent;
        children: [ "inputbar", "listview" ];
        spacing: 10px;
        padding: 10px;
      }

      inputbar {
        background-color: @surface0;
        text-color: @text;
        border-radius: 4px;
        padding: 8px 12px;
        children: [ "prompt", "entry" ];
      }

      prompt {
        background-color: transparent;
        text-color: @mauve;
        padding: 0px 8px 0px 0px;
      }

      entry {
        background-color: transparent;
        text-color: @text;
        placeholder-color: @subtext0;
        cursor: text;
      }

      listview {
        background-color: transparent;
        margin: 0px 0px 0px 0px;
        spacing: 2px;
        cycle: true;
        dynamic: true;
        layout: vertical;
      }

      element {
        background-color: transparent;
        text-color: @text;
        orientation: horizontal;
        border-radius: 4px;
        padding: 8px 12px 8px 12px;
      }

      element-icon {
        background-color: transparent;
        text-color: inherit;
        size: 24px;
        cursor: inherit;
      }

      element-text {
        background-color: transparent;
        text-color: inherit;
        cursor: inherit;
        vertical-align: 0.5;
        horizontal-align: 0.0;
      }

      element normal.normal {
        background-color: transparent;
        text-color: @text;
      }

      element normal.urgent {
        background-color: @red;
        text-color: @base;
      }

      element normal.active {
        background-color: @green;
        text-color: @base;
      }

      element selected.normal {
        background-color: @mauve;
        text-color: @base;
      }

      element selected.urgent {
        background-color: @red;
        text-color: @base;
      }

      element selected.active {
        background-color: @green;
        text-color: @base;
      }

      element alternate.normal {
        background-color: transparent;
        text-color: @text;
      }

      element alternate.urgent {
        background-color: @red;
        text-color: @base;
      }

      element alternate.active {
        background-color: @green;
        text-color: @base;
      }

      mode-switcher {
        background-color: @surface0;
        text-color: @text;
        border-radius: 4px;
        margin: 10px 0px 0px 0px;
      }

      button {
        background-color: transparent;
        text-color: @subtext0;
        border-radius: 4px;
        padding: 8px 12px;
      }

      button selected {
        background-color: @mauve;
        text-color: @base;
      }

      scrollbar {
        width: 4px;
        border: 0px;
        handle-color: @surface1;
        handle-width: 8px;
        padding: 0;
      }

      message {
        background-color: @surface0;
        border-radius: 4px;
        padding: 8px;
        margin: 10px 0px 0px 0px;
      }

      textbox {
        background-color: transparent;
        text-color: @text;
        vertical-align: 0.5;
        horizontal-align: 0.0;
      }
    '';

    # Waybar CSS styling with Catppuccin theme
    xdg.configFile."waybar/style.css".text = ''
      /* Catppuccin Frappe Colors */
      @define-color rosewater #f2d5cf;
      @define-color flamingo #eebebe;
      @define-color pink #f4b8e4;
      @define-color mauve #ca9ee6;
      @define-color red #e78284;
      @define-color maroon #ea999c;
      @define-color peach #ef9f76;
      @define-color yellow #e5c890;
      @define-color green #a6d189;
      @define-color teal #81c8be;
      @define-color sky #99d1db;
      @define-color sapphire #85c1dc;
      @define-color blue #8caaee;
      @define-color lavender #babbf1;
      @define-color text #c6d0f5;
      @define-color subtext1 #b5bfe2;
      @define-color subtext0 #a5adce;
      @define-color overlay2 #949cbb;
      @define-color overlay1 #838ba7;
      @define-color overlay0 #737994;
      @define-color surface2 #626880;
      @define-color surface1 #51576d;
      @define-color surface0 #414559;
      @define-color base #303446;
      @define-color mantle #292c3c;
      @define-color crust #232634;

      * {
        border: none;
        border-radius: 0;
        font-family: "FiraCode Nerd Font", monospace;
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: @base;
        color: @text;
      }

      tooltip {
        background: @surface0;
        color: @text;
        border-radius: 8px;
        border: 1px solid @surface1;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: @subtext0;
        border-radius: 4px;
        transition: all 0.3s ease;
      }

      #workspaces button:hover {
        background: @surface0;
        color: @text;
      }

      #workspaces button.focused,
      #workspaces button.active {
        background: @mauve;
        color: @base;
      }

      #workspaces button.urgent {
        background: @red;
        color: @base;
      }

      #mode {
        background: @yellow;
        color: @base;
        padding: 0 10px;
        margin: 0 4px;
        border-radius: 4px;
      }

      #window {
        color: @text;
        font-weight: bold;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        margin: 0 2px;
        border-radius: 4px;
        background: @surface0;
        color: @text;
      }

      #battery.charging {
        background: @green;
        color: @base;
      }

      #battery.warning:not(.charging) {
        background: @yellow;
        color: @base;
      }

      #battery.critical:not(.charging) {
        background: @red;
        color: @base;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background-color: @maroon;
        }
      }

      #cpu.warning {
        background: @yellow;
        color: @base;
      }

      #cpu.critical {
        background: @red;
        color: @base;
      }

      #memory.warning {
        background: @yellow;
        color: @base;
      }

      #memory.critical {
        background: @red;
        color: @base;
      }

      #temperature.critical {
        background: @red;
        color: @base;
      }

      #network.disconnected {
        background: @red;
        color: @base;
      }

      #pulseaudio.muted {
        background: @surface1;
        color: @subtext0;
      }

      #tray menu {
        background: @surface0;
        color: @text;
        border: 1px solid @surface1;
        border-radius: 4px;
      }
    '';

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
