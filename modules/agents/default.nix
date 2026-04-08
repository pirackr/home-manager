{ config, lib, pkgs, ... }:

let
  cfg = config.modules.agents;

  # Base path for agents module (for runtime symlinks)
  agentsPath = "${config.home.homeDirectory}/.config/home-manager/modules/agents";

  # MCP server submodule type (shared across all AI tools)
  mcpServerType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [ "stdio" "sse" "http" ];
        default = "stdio";
        description = "MCP server transport type.";
      };
      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Command to start stdio MCP server.";
      };
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Arguments for the MCP server command.";
      };
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL for SSE/HTTP MCP server.";
      };
      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Environment variables for the MCP server.";
      };
      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "HTTP headers for SSE/HTTP MCP servers.";
      };
      oauth = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "OAuth configuration for remote MCP servers (e.g. clientId, callbackPort).";
      };
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Rendered MCP server name for tool configs; defaults to the attribute name.";
      };
      enableFor = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "claude" "cursor" ]);
        default = [ "claude" "cursor" ];
        description = "Which AI tools this MCP server is enabled for.";
      };
    };
  };

  # Command/skill submodule type (shared across all AI tools)
  commandType = lib.types.submodule {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Short description of the command/skill.";
      };
      file = lib.mkOption {
        type = lib.types.path;
        description = "Path to the markdown prompt file.";
      };
    };
  };

  commands = cfg.commands;

  # Render a single MCP server to the .mcp.json format (Claude/Cursor style)
  renderMcpServer = name: server:
    if server.type == "stdio" then
      { command = server.command; args = server.args; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; }
    else
      { type = server.type; url = server.url; }
      // lib.optionalAttrs (server.headers != { }) { headers = server.headers; }
      // lib.optionalAttrs (server.oauth != { }) { oauth = server.oauth; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; };

  # Filter MCP servers for a specific tool
  mcpServersFor = tool:
    lib.filterAttrs (_: server: builtins.elem tool server.enableFor) cfg.mcpServers;

  # Render all MCP servers for a tool into { mcpServers = { ... } }
  renderMcpJson = tool:
    let
      servers = mcpServersFor tool;
      renderedServers = lib.listToAttrs (map (attrName:
        let server = servers.${attrName};
        in {
          name = if server.name != null then server.name else attrName;
          value = renderMcpServer attrName server;
        }
      ) (builtins.attrNames servers));
    in { mcpServers = renderedServers; };

in
{
  options.modules.agents = {
    enable = lib.mkEnableOption "agents configuration and skills";

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf mcpServerType;
      default = { };
      description = "Shared MCP server definitions across AI tools.";
    };

    commands = lib.mkOption {
      type = lib.types.attrsOf commandType;
      default = { };
      description = "Custom commands/skills deployed to all AI agents.";
    };

    claude = {
      enable = lib.mkEnableOption "Claude Code configuration";
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Claude Code settings (model, env, statusLine, etc).";
      };
      enabledPlugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of Claude Code plugins to enable (e.g. \"superpowers@superpowers-marketplace\").";
      };
      extraKnownMarketplaces = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = { };
        description = "Extra known marketplaces for Claude Code plugins.";
      };
    };

  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge [
      {
        # Shared instructions symlinked to Claude's CLAUDE.md
        ".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink
          "${agentsPath}/AGENTS.md";
      }

      # ~/.mcp.json — picked up by Claude Code via directory walk-up
      (lib.mkIf (cfg.mcpServers != { }) {
        ".mcp.json".text = builtins.toJSON (renderMcpJson "claude");
      })

      # Claude Code settings
      (lib.mkIf cfg.claude.enable {
        ".claude/settings.json".text = builtins.toJSON (
          cfg.claude.settings
          // lib.optionalAttrs (cfg.claude.enabledPlugins != [ ]) {
            enabledPlugins = builtins.listToAttrs (map (p: {
              name = p;
              value = true;
            }) cfg.claude.enabledPlugins);
          }
          // lib.optionalAttrs (cfg.claude.extraKnownMarketplaces != { }) {
            extraKnownMarketplaces = cfg.claude.extraKnownMarketplaces;
          }
        );
      })

      # Commands/skills — Claude Code
      (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".claude/commands/${name}.md" {
          source = cmd.file;
        }
      ) commands)
    ];
  };
}
