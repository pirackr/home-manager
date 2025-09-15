{ config, pkgs, lib, ... }:

{
  options.modules.mako = {
    enable = lib.mkEnableOption "Mako notification daemon with Catppuccin theme";
  };

  config = lib.mkIf config.modules.mako.enable {
    services.mako = {
      enable = true;
      
      settings = {
        # Catppuccin Frappe color scheme (official colors)
        background-color = "#303446";
        text-color = "#c6d0f5";
        border-color = "#babbf1";
        progress-color = "over #414559";
        
        # Professional styling
        border-size = 2;
        border-radius = 12;           # More modern rounded corners
        padding = "15,20";            # Asymmetric padding (vertical, horizontal)
        margin = "10";
        
        # Typography
        font = "Noto Sans Medium 11";  # Medium weight for better readability
        markup = true;                # Enable markup for rich text
        
        # Positioning & Layout
        anchor = "top-right";
        output = "";                  # Use all outputs
        
        # Professional behavior
        default-timeout = 8000;       # Longer timeout for better UX
        ignore-timeout = false;       # Respect app timeouts
        max-visible = 4;              # Clean, not overwhelming
        sort = "-time";
        
        # Fixed dimensions for consistency
        width = 420;                  # Wider for better content display
        height = 120;                 # Fixed height for uniformity
        min-height = 80;              # Minimum height for small notifications
        max-height = 200;             # Maximum height for long content
        
        # Professional icon configuration
        icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark:${pkgs.papirus-icon-theme}/share/icons/Papirus";
        max-icon-size = 64;           # Larger icons for visibility
        icons = true;                 # Enable icons
        
        # Advanced features
        group-by = "app-name,summary"; # Better grouping
        actions = true;               # Interactive notifications
        history = true;               # Enable notification history
        max-history = 20;             # Keep reasonable history
        
        # Layer management (Wayland)
        layer = "overlay";
        
        # Text formatting
        format = "<b>%s</b>\\n%b";    # Bold summary, normal body
        text-alignment = "left";      # Left-aligned text
        
        # Advanced positioning
        outer-margin = "0,10,10,0";   # top,right,bottom,left margins
        
        # Mouse interaction
        on-button-left = "dismiss";
        on-button-middle = "none";
        on-button-right = "dismiss-all";
        on-touch = "dismiss";
        
        # Mouse and touch interaction
        # on-notify = ""; # Optional: add sound notification command here
      };
      
      # Professional urgency and app-specific configurations
      extraConfig = ''
        # Low priority notifications (subtle)
        [urgency=low]
        border-color=#737994
        background-color=#292c3c
        text-color=#949cbb
        default-timeout=5000
        border-size=1
        max-icon-size=32
        
        # Normal notifications (default Catppuccin colors)
        [urgency=normal]
        border-color=#babbf1
        background-color=#303446
        text-color=#c6d0f5
        default-timeout=8000
        
        # Critical notifications (attention-grabbing)
        [urgency=high]
        border-color=#ef9f76
        background-color=#303446
        text-color=#c6d0f5
        default-timeout=0
        border-size=3
        
        # Media player notifications
        [category=mpd]
        [app-name="Spotify"]
        [app-name="mpv"]
        [app-name="VLC"]
        border-color=#a6d189
        default-timeout=4000
        group-by=category
        max-icon-size=80
        width=450
        
        # System notifications
        [app-name="NetworkManager"]
        [app-name="bluetoothctl"]
        [app-name="systemd"]
        border-color=#85c1dc
        default-timeout=6000
        max-icon-size=48
        
        # Screenshot/screen recording
        [app-name="screenshot"]
        [app-name="flameshot"]
        [app-name="grimshot"]
        [category=screenshot]
        border-color=#85c1dc
        default-timeout=3000
        max-icon-size=48
        
        # Chat and communication
        [app-name="Discord"]
        [app-name="Slack"]
        [app-name="Teams"]
        [app-name="Telegram"]
        border-color=#ca9ee6
        default-timeout=10000
        group-by=app-name
        
        # Development tools
        [app-name="git"]
        [app-name="Docker"]
        [app-name="Code"]
        [app-name="code"]
        border-color=#8caaee
        default-timeout=5000
        
        # Package managers
        [app-name="paru"]
        [app-name="yay"]
        [app-name="pacman"]
        [app-name="nix"]
        border-color=#a6d189
        default-timeout=8000
        
        # Email
        [app-name="Thunderbird"]
        [app-name="Evolution"]
        [category=email]
        border-color=#f4b8e4
        default-timeout=12000
        group-by=app-name
      '';
    };
    
    # Ensure mako package is available
    home.packages = with pkgs; [
      mako
      libnotify  # For notify-send command
    ];
  };
}