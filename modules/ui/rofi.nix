{ config, pkgs, lib, ... }:

{
  options.modules.ui.rofi = {
    enable = lib.mkEnableOption "Rofi application launcher with Catppuccin theme";
  };

  config = lib.mkIf config.modules.ui.rofi.enable {
    home.packages = with pkgs; [
      rofi
    ];

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

        accent: @mauve;
        urgent: @red;
        on: @green;
        off: @red;

        font: "FiraCode Nerd Font 12";
      }

      window {
        background-color: @base;
        border: 2px solid;
        border-color: @accent;
        border-radius: 10px;
        width: 600px;
        location: center;
        anchor: center;
      }

      mainbox {
        background-color: transparent;
        padding: 20px;
        spacing: 10px;
      }

      inputbar {
        background-color: @surface0;
        text-color: @text;
        border-radius: 8px;
        padding: 10px;
        spacing: 10px;
      }

      prompt {
        background-color: transparent;
        text-color: @accent;
      }

      textbox-prompt-colon {
        expand: false;
        str: ":";
        text-color: @accent;
      }

      entry {
        background-color: transparent;
        text-color: @text;
        placeholder-color: @overlay0;
        cursor: text;
      }

      listview {
        background-color: transparent;
        columns: 1;
        lines: 8;
        spacing: 5px;
        cycle: true;
        dynamic: true;
        layout: vertical;
      }

      element {
        background-color: transparent;
        text-color: @text;
        border-radius: 8px;
        padding: 8px;
      }

      element-icon {
        background-color: transparent;
        size: 32px;
        cursor: inherit;
      }

      element-text {
        background-color: transparent;
        text-color: inherit;
        cursor: inherit;
        vertical-align: 0.5;
        horizontal-align: 0.0;
      }

      element selected {
        background-color: @accent;
        text-color: @base;
      }

      element selected.urgent {
        background-color: @urgent;
        text-color: @base;
      }

      element selected.active {
        background-color: @on;
        text-color: @base;
      }

      mode-switcher {
        background-color: transparent;
        spacing: 10px;
      }

      button {
        background-color: @surface0;
        text-color: @text;
        border-radius: 8px;
        padding: 8px 16px;
      }

      button selected {
        background-color: @accent;
        text-color: @base;
      }

      message {
        background-color: transparent;
        border: 0px;
        border-color: @accent;
        border-radius: 10px;
      }

      textbox {
        background-color: transparent;
        text-color: @text;
        vertical-align: 0.5;
        horizontal-align: 0.0;
      }
    '';
  };
}
