{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./fish.nix
    ./vim.nix
    ./emacs/default.nix
    ./k8s.nix
    ./fcitx.nix
    ./ui
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please rea the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.neofetch
    pkgs.nix-prefetch-github
    pkgs.nixpkgs-fmt
    pkgs.curl
    pkgs.wget
    pkgs.less
    pkgs.ripgrep
    pkgs.htop
    pkgs.claude-code
    pkgs.codex
    pkgs.openssh
    pkgs.kind
    pkgs.kubernetes-helm

    pkgs.enchant
    pkgs.hunspell
    pkgs.hunspellDicts.en_US

    # Language server performance booster
    pkgs.emacs-lsp-booster

    # Language servers
    pkgs.nixd
    pkgs.yaml-language-server

    # Fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-emoji # Emoji support
    pkgs.noto-fonts-extra
    pkgs.nerd-fonts.fira-code
    pkgs.font-awesome # FontAwesome icons

    pkgs.nodejs
    pkgs.uv
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.firefox
    pkgs.pcmanfm
    pkgs.pwvucontrol
    pkgs.lm_sensors
  ];

  # Font configuration for proper emoji support
  # NOTE: fontconfig should be installed as systemPackages in NixOS configuration:
  # environment.systemPackages = [ pkgs.fontconfig ];
  fonts.fontconfig.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3599999
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hhnguyen/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR is now set by vim module
    EDITOR = "vim";
  };

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Configure tmux
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    baseIndex = 1; # Start window numbering at 1
    escapeTime = 0; # No delay for escape key press
    keyMode = "emacs"; # Use vi-style key bindings
    mouse = true; # Enable mouse support

    # Terminal settings
    terminal = "xterm-kitty";

    # Additional configuration
    extraConfig = ''
      # Reload config file
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Pane splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Pane navigation with vi-style keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Window navigation
      bind -n M-H previous-window
      bind -n M-L next-window

      # Copy mode improvements
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Status bar styling (Catppuccin Frappe theme to match kitty)
      set -g status-bg "#303446"
      set -g status-fg "#c6d0f5"
      set -g status-left-length 40
      set -g status-right-length 50
      set -g status-left "#[fg=#303446,bg=#ca9ee6,bold] #S #[fg=#ca9ee6,bg=#303446]"
      set -g status-right "#[fg=#737994]%H:%M %d-%b-%y"

      # Window status styling
      set -g window-status-format "#[fg=#737994] #I:#W "
      set -g window-status-current-format "#[fg=#303446,bg=#a6d189,bold] #I:#W #[fg=#a6d189,bg=#303446]"

      # Pane border styling
      set -g pane-border-style "fg=#737994"
      set -g pane-active-border-style "fg=#ca9ee6"

      # Message styling
      set -g message-style "bg=#e78284,fg=#303446"

      # Clock styling
      set -g clock-mode-colour "#8caaee"
    '';
  };

  # Configure kitty terminal
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font Mono Regular";
      size = 16;
    };
    settings = {
      # Basic settings
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;

      # Font settings
      disable_ligatures = "never";

      # Window settings
      remember_window_size = false;
      initial_window_width = 500;
      initial_window_height = 300;

      # Start in fullscreen mode
      startup_session = "none";
      hide_window_decorations = "titlebar-only";
      # Note: kitty doesn't have a direct fullscreen option, but we can simulate it
      # You can press Cmd+Ctrl+F (macOS) or F11 (Linux) to toggle fullscreen after startup

      # Tab settings
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";

      # Catppuccin Frappe theme
      background_opacity = "0.95";

      # Catppuccin Frappe colors
      foreground = "#c6d0f5";
      background = "#303446";
      selection_foreground = "#303446";
      selection_background = "#f2d5cf";

      # Cursor colors
      cursor = "#f2d5cf";
      cursor_text_color = "#303446";

      # URL underline color when hovering with mouse
      url_color = "#f2d5cf";

      # Kitty window border colors
      active_border_color = "#babbf1";
      inactive_border_color = "#737994";
      bell_border_color = "#e5c890";

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      # Tab bar colors
      active_tab_foreground = "#232634";
      active_tab_background = "#ca9ee6";
      inactive_tab_foreground = "#c6d0f5";
      inactive_tab_background = "#292c3c";
      tab_bar_background = "#232634";

      # Colors for marks (marked text in the terminal)
      mark1_foreground = "#303446";
      mark1_background = "#babbf1";
      mark2_foreground = "#303446";
      mark2_background = "#ca9ee6";
      mark3_foreground = "#303446";
      mark3_background = "#85c1dc";

      # The 16 terminal colors

      # black
      color0 = "#51576d";
      color8 = "#626880";

      # red
      color1 = "#e78284";
      color9 = "#e78284";

      # green
      color2 = "#a6d189";
      color10 = "#a6d189";

      # yellow
      color3 = "#e5c890";
      color11 = "#e5c890";

      # blue
      color4 = "#8caaee";
      color12 = "#8caaee";

      # magenta
      color5 = "#f4b8e4";
      color13 = "#f4b8e4";

      # cyan
      color6 = "#81c8be";
      color14 = "#81c8be";

      # white
      color7 = "#b5bfe2";
      color15 = "#a5adce";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
  };

  # Configure Nix experimental features via user config file
  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Enable Emacs daemon service
  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };
}
