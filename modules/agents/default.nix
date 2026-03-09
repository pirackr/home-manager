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
      enableFor = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "claude" "codex" "opencode" "cursor" ]);
        default = [ "claude" "codex" "opencode" "cursor" ];
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

  # Prepend Codex YAML frontmatter to a command prompt
  renderCodexPrompt = name: cmd:
    ''
      ---
      description: "${cmd.description}"
      argument-hint: ""
      ---
    '' + builtins.readFile cmd.file;

  # Prepend OpenCode YAML frontmatter to a command prompt
  renderOpenCodeSkill = name: cmd:
    ''
      ---
      name: "${name}"
      description: "${cmd.description}"
      ---
    '' + builtins.readFile cmd.file;

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
        ".claude/settings.json".text = builtins.toJSON (
          cfg.claude.settings
          // lib.optionalAttrs (cfg.claude.enabledPlugins != [ ]) {
            enabledPlugins = builtins.listToAttrs (map (p: {
              name = p;
              value = true;
            }) cfg.claude.enabledPlugins);
          }
        );
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

      # Commands/skills — Claude Code
      (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".claude/commands/${name}.md" {
          source = cmd.file;
        }
      ) cfg.commands)

      # Commands/skills — Codex (with YAML frontmatter)
      (lib.mkIf cfg.codex.enable (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".codex/prompts/${name}.md" {
          text = renderCodexPrompt name cmd;
        }
      ) cfg.commands))

      # Commands/skills — OpenCode (with YAML frontmatter)
      (lib.mkIf cfg.opencode.enable (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".config/opencode/skills/${name}/SKILL.md" {
          text = renderOpenCodeSkill name cmd;
        }
      ) cfg.commands))
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
