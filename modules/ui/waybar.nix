{ config, pkgs, lib, ... }:

{
  options.modules.ui.waybar = {
    enable = lib.mkEnableOption "Waybar status bar with Catppuccin theme";
  };

  config = lib.mkIf config.modules.ui.waybar.enable {
    home.packages = with pkgs; [
      waybar
      pwvucontrol
    ];

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
        on-click = "hyprctl dispatch togglespecialworkspace scratchpad";
      };

      "hyprland/window" = {
        format = "{}";
        max-length = 50;
        separate-outputs = true;
      };

      "tray" = {
        spacing = 10;
      };

      "clock" = {
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%Y-%m-%d %H:%M}";
        format-alt = "{:%A, %B %d, %Y}";
      };

      "cpu" = {
        format = "  {usage}%";
        tooltip = false;
      };

      "memory" = {
        format = "  {}%";
      };

      "temperature" = {
        critical-threshold = 80;
        format-critical = " {temperatureC}°C";
        format = " {temperatureC}°C";
      };

      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-alt = "{icon} {time}";
        format-icons = ["" "" "" "" ""];
      };

      "network" = {
        format-wifi = "  {essid} ({signalStrength}%)";
        format-ethernet = "  {ipaddr}/{cidr}";
        tooltip-format = "  {ifname} via {gwaddr}";
        format-linked = "  {ifname} (No IP)";
        format-disconnected = "⚠  Disconnected";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-bluetooth = "{icon} {volume}% ";
        format-bluetooth-muted = " {icon}";
        format-muted = " {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = ["" "" ""];
        };
        on-click = "pwvucontrol";
      };
    };

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
        font-family: "FiraCode Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: @text;
      }

      #workspaces button {
        padding: 0 8px;
        background: @surface0;
        color: @subtext1;
        border-radius: 4px;
        margin: 4px 2px;
      }

      #workspaces button.active {
        background: @mauve;
        color: @base;
      }

      #workspaces button:hover {
        background: @surface1;
        color: @text;
      }

      #mode, #clock, #battery, #cpu, #memory, #temperature, #network, #pulseaudio, #tray, #window, #scratchpad {
        background: @surface0;
        padding: 0 10px;
        margin: 4px 2px;
        border-radius: 4px;
        color: @text;
      }

      #battery.charging, #battery.plugged {
        color: @green;
      }

      #battery.critical:not(.charging) {
        color: @red;
      }

      #battery.warning:not(.charging) {
        color: @yellow;
      }

      #cpu {
        color: @blue;
      }

      #memory {
        color: @mauve;
      }

      #temperature {
        color: @peach;
      }

      #temperature.critical {
        color: @red;
      }

      #network {
        color: @teal;
      }

      #network.disconnected {
        color: @red;
      }

      #pulseaudio {
        color: @yellow;
      }

      #pulseaudio.muted {
        color: @overlay0;
      }

      #clock {
        color: @lavender;
      }

      #tray {
        color: @text;
        border: 1px solid @surface1;
        border-radius: 4px;
      }
    '';
  };
}