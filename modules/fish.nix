{ config, pkgs, lib, ... }:

{
  options.modules.fish = {
    enable = lib.mkEnableOption "Fish shell configuration";
  };

  config = lib.mkIf config.modules.fish.enable {
    home.packages = with pkgs; [
      grc
    ];

    programs.fish = {
      enable = true;
      shellAliases = {
        gemini = "npx https://github.com/google-gemini/gemini-cli";
        ccusage = "npx ccusage";
      };
      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        # Why don't it do this itself?
        if test -f /etc/profile.d/nix-daemon.fish
          source /etc/profile.d/nix-daemon.fish
        end
      '';

      plugins = [
        { name = "grc"; src = pkgs.fishPlugins.grc.src; }
        { name = "plugin-git"; src = pkgs.fishPlugins.plugin-git.src; }
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
            rev = "4aadb2649fd3420e6515016f869eb79455807aaa";
            hash = "sha256-cuCZjISIsAahZ3lDFnjCcawrEOdsFXgI8+slzv2LyGc=";
          };
        }
      ];
    };
  };
}
