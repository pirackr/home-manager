{ config, lib, pkgs, ... }:

let
  cfg = config.modules.agents;

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

  };

  config = lib.mkIf cfg.enable {
    home.file = { };
  };
}
