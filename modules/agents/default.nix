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
      enableFor = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "claude" "codex" "opencode" "cursor" ]);
        default = [ "claude" "codex" "opencode" "cursor" ];
        description = "Which AI tools this MCP server is enabled for.";
      };
    };
  };
  # Render a single MCP server to the .mcp.json format (Claude/Cursor style)
  renderMcpServer = name: server:
    if server.type == "stdio" then
      { command = server.command; args = server.args; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; }
    else
      { type = server.type; url = server.url; }
      // lib.optionalAttrs (server.headers != { }) { headers = server.headers; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; };

  # Filter MCP servers for a specific tool
  mcpServersFor = tool:
    lib.filterAttrs (_: server: builtins.elem tool server.enableFor) cfg.mcpServers;

  # Render all MCP servers for a tool into { mcpServers = { ... } }
  renderMcpJson = tool:
    let servers = mcpServersFor tool;
    in { mcpServers = lib.mapAttrs renderMcpServer servers; };
in
{
  options.modules.agents = {
    enable = lib.mkEnableOption "agents configuration and skills";

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf mcpServerType;
      default = { };
      description = "Shared MCP server definitions across AI tools.";
    };

    claude = {
      enable = lib.mkEnableOption "Claude Code configuration";
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Claude Code settings (model, env, plugins, statusLine, etc).";
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
        ".claude/settings.json".text = builtins.toJSON cfg.claude.settings;
      })
    ];
  };
}
