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

  # Render a single MCP server to OpenCode format (explicit type, "http" -> "remote")
  renderOpenCodeMcpServer = name: server:
    if server.type == "stdio" then
      { type = "stdio"; command = server.command; args = server.args; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; }
    else
      { type = if server.type == "http" then "remote" else server.type; url = server.url; }
      // lib.optionalAttrs (server.headers != { }) { headers = server.headers; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; };

  # Filter MCP servers for a specific tool
  mcpServersFor = tool:
    lib.filterAttrs (_: server: builtins.elem tool server.enableFor) cfg.mcpServers;

  # Render all MCP servers for a tool into { mcpServers = { ... } }
  renderMcpJson = tool:
    let servers = mcpServersFor tool;
    in { mcpServers = lib.mapAttrs renderMcpServer servers; };

  # Render OpenCode config with MCP servers and extra settings merged
  renderOpenCodeConfig = let
    servers = mcpServersFor "opencode";
    mcpPart = lib.optionalAttrs (servers != { }) {
      mcpServers = lib.mapAttrs renderOpenCodeMcpServer servers;
    };
  in cfg.opencode.settings // mcpPart;

  # Render Codex MCP servers as TOML using pkgs.formats.toml
  codexMcpServers = mcpServersFor "codex";
  codexMcpTomlFile = (pkgs.formats.toml { }).generate "codex-mcp.toml" {
    mcp_servers = lib.mapAttrs (name: server:
      { command = server.command; args = server.args; }
      // lib.optionalAttrs (server.env != { }) { env = server.env; }
    ) codexMcpServers;
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

    claude = {
      enable = lib.mkEnableOption "Claude Code configuration";
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Claude Code settings (model, env, plugins, statusLine, etc).";
      };
    };

    opencode = {
      enable = lib.mkEnableOption "OpenCode configuration";
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "OpenCode settings (providers, agents, shell, etc).";
      };
    };

    codex = {
      enable = lib.mkEnableOption "Codex CLI configuration";
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

      # OpenCode config + AGENTS.md
      (lib.mkIf cfg.opencode.enable {
        ".config/opencode/opencode.json".text = builtins.toJSON renderOpenCodeConfig;
        ".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink
          "${agentsPath}/AGENTS.md";
      })

      # Codex AGENTS.md
      (lib.mkIf cfg.codex.enable {
        ".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink
          "${agentsPath}/AGENTS.md";
      })
    ];

    # Codex: patch mcp_servers in config.toml via activation script
    # (config.toml has runtime state like [projects.*] we must preserve)
    home.activation.codexMcpServers = lib.mkIf (cfg.codex.enable && codexMcpServers != { }) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CODEX_CONFIG="${config.home.homeDirectory}/.codex/config.toml"
        if [ -f "$CODEX_CONFIG" ]; then
          # Remove existing [mcp_servers.*] sections
          ${pkgs.gawk}/bin/awk '
            /^\[mcp_servers\./ { skip=1; next }
            /^\[/ { skip=0 }
            !skip { print }
          ' "$CODEX_CONFIG" > "$CODEX_CONFIG.tmp"
          # Append Nix-generated MCP servers
          cat ${codexMcpTomlFile} >> "$CODEX_CONFIG.tmp"
          mv "$CODEX_CONFIG.tmp" "$CODEX_CONFIG"
        else
          mkdir -p "$(dirname "$CODEX_CONFIG")"
          cp ${codexMcpTomlFile} "$CODEX_CONFIG"
        fi
      ''
    );
  };
}
