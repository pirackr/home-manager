{ config, pkgs, lib, ... }:

{
 
 imports = with builtins;
    map (name: ./configurations + "/${name}") (attrNames (readDir ./configurations));

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "pirackr";
  home.homeDirectory = "/home/pirackr";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.hello 
    pkgs.neofetch 
    pkgs.aider-chat
    pkgs.nix-prefetch-github
    pkgs.firefox
    pkgs.wl-clipboard
    pkgs.noto-fonts
    pkgs.nerd-fonts.fira-code
    pkgs.rofi-wayland
    pkgs.pcmanfm
    pkgs.numix-gtk-theme
    pkgs.numix-cursor-theme
    pkgs.numix-icon-theme
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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
  #  /etc/profiles/per-user/pirackr/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    GEMINI_API_KEY = "AIzaSyAXA8L7OnLk4lnQDN47ES552s5_cetu6j4";
  };

  programs.git = {
    enable = true;
    userName  = "Pirackr";
    userEmail = "pirackr.inbox@gmail.com";
  };


  programs.emacs = {
    enable = true;
    package = pkgs.emacs;  # replace with pkgs.emacs-gtk, or a version provided by the community overlay if desired.
    extraConfig = ''
      (setq standard-indent 2)
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';

    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
    	  repo = "plugin-foreign-env";
    	  rev = "7f0cf099ae1e1e4ab38f46350ed6757d54471de7";
    	  hash = "sha256-4+k5rSoxkTtYFh/lEjhRkVYa2S4KEzJ/IJbyJl+rJjQ=";
	};
      }
      {
        name = "theme-l";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
    	  repo = "theme-l";
          rev = "4aadb2649fd3421e6515016f869eb79455807aaa";
          hash = "sha256-cuCZjISIsAahZ3lDFnjCcawrEOdsFXgI8+slzv2LyGc=";
        };
      }
    ];
  };

  programs.bash.enable = true; 
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
