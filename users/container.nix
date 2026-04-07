{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/agents
  ];

  home.username = "dev";
  home.homeDirectory = "/home/dev";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.file = {
    # Keep generated agent symlinks valid inside the container by exposing the
    # mounted host home-manager tree at the path the shared module expects.
    ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink "/mnt/home-manager";

    ".claude/settings.local.json".text = builtins.toJSON {
      outputStyle = "default";
    };
  };

  modules.agents = {
    enable = true;

    claude = {
      enable = true;
      settings = {
        env = {
          ENABLE_TOOL_SEARCH = "true";
          ENABLE_LSP_TOOL = "1";
        };
        model = "opus";
      };
      enabledPlugins = [
        "superpowers@claude-plugins-official"
        "context-mode@context-mode"
      ];
      extraKnownMarketplaces = {
        superpowers-marketplace = {
          source = {
            source = "github";
            repo = "obra/superpowers-marketplace";
          };
        };
        context-mode = {
          source = {
            source = "github";
            repo = "mksglu/context-mode";
          };
        };
      };
    };

    opencode = {
      enable = true;
      settings = {
        compaction.auto = true;
        plugin = [
          "superpowers@git+https://github.com/obra/superpowers.git"
          "autopilot@git+ssh://git@github.com/pirackr/autopilot.git"
        ];
      };
    };

    mcpServers = {
      context-mode = {
        command = "npx";
        args = [ "-y" "context-mode" ];
        enableFor = [ "opencode" ];
      };
    };
  };
}
