{ config, lib, pkgs, ralph ? null, ... }:

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

  # Prepend OpenCode command frontmatter
  renderOpenCodeCommand = name: cmd:
    ''
      ---
      description: "${cmd.description}"
      argument-hint: ""
      ---
    '' + builtins.readFile cmd.file;

  builtinCommands = {
    init-deep = {
      description = "Initialize hierarchical AGENTS.md knowledge base";
      file = ./commands/init-deep.md;
    };
    ralph = {
      description = "Convert requirements into Ralph format and point to the managed runner";
      file = ./commands/ralph.md;
    };
  };

  commands = builtinCommands // cfg.commands;

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

  # Render a single MCP server to OpenCode format
  # OpenCode uses: root key "mcp", type "local"/"remote", command as array, environment (not env), enabled flag
  renderOpenCodeMcpServer = name: server:
    if server.type == "stdio" then
      { type = "local"; enabled = true; command = [ server.command ] ++ server.args; }
      // lib.optionalAttrs (server.env != { }) { environment = server.env; }
    else
      { type = "remote"; enabled = true; url = server.url; }
      // lib.optionalAttrs (server.headers != { }) { headers = server.headers; }
      // lib.optionalAttrs (server.oauth != { }) {
        oauth = lib.filterAttrs (k: _: builtins.elem k [ "clientId" "clientSecret" "scope" ]) server.oauth;
      };

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

  # Render OpenCode config with MCP servers and extra settings merged
  renderOpenCodeConfig = let
    servers = mcpServersFor "opencode";
    mcpPart = lib.optionalAttrs (servers != { }) {
      mcp = lib.listToAttrs (map (attrName:
        let server = servers.${attrName};
        in {
          name = if server.name != null then server.name else attrName;
          value = renderOpenCodeMcpServer attrName server;
        }
      ) (builtins.attrNames servers));
    };
  in cfg.opencode.settings // mcpPart;

  codexMcpServers = mcpServersFor "codex";
  codexConfigToml = cfg.codex.settings // lib.optionalAttrs (codexMcpServers != { }) {
    mcp_servers = lib.listToAttrs (map (attrName:
      let server = codexMcpServers.${attrName};
      in {
        name = if server.name != null then server.name else attrName;
        value =
          if server.type == "stdio" then
            { command = server.command; args = server.args; }
            // lib.optionalAttrs (server.env != { }) { env = server.env; }
          else
            { url = server.url; }
            // lib.optionalAttrs (server.oauth != { }) { oauth = server.oauth; };
      }
    ) (builtins.attrNames codexMcpServers));
  };
  codexConfigTomlFile = (pkgs.formats.toml { }).generate "codex-config.toml" codexConfigToml;
  localAgentSkillTrees = lib.mapAttrsToList (name: cmd:
    pkgs.writeTextDir "local-skills/${name}/SKILL.md" (renderOpenCodeSkill name cmd)
  ) commands;
  localAgentSkillsDir = pkgs.buildEnv {
    name = "local-agent-skills";
    paths = localAgentSkillTrees;
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
      extraKnownMarketplaces = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = { };
        description = "Extra known marketplaces for Claude Code plugins.";
      };
    };

    opencode = {
      enable = lib.mkEnableOption "OpenCode configuration";
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "OpenCode settings (providers, agents, shell, etc).";
      };
      superpowersPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to superpowers repo for OpenCode plugin and skills.";
      };
};

    codex = {
      enable = lib.mkEnableOption "Codex CLI configuration";
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Codex CLI settings written to config.toml.";
      };
      superpowersPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to superpowers repo for Codex skills.";
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

      # OpenCode config + AGENTS.md
      (lib.mkIf cfg.opencode.enable {
        ".config/opencode/opencode.json".text = builtins.toJSON renderOpenCodeConfig;
        ".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink
          "${agentsPath}/AGENTS.md";
      })


      # OpenCode superpowers plugin + skills
      (lib.mkIf (cfg.opencode.enable && cfg.opencode.superpowersPath != null) {
        ".config/opencode/plugins/superpowers.js".source =
          "${cfg.opencode.superpowersPath}/.opencode/plugins/superpowers.js";
        ".config/opencode/skills/superpowers".source =
          "${cfg.opencode.superpowersPath}/skills";
      })

      # OpenCode Ralph skill + script
      (lib.mkIf (cfg.opencode.enable && ralph != null) {
        ".config/opencode/skills/ralph".source =
          "${ralph}/skills/ralph";
        ".config/opencode/scripts/ralph.sh".source =
          "${ralph}/ralph.sh";
      })

      # Codex AGENTS.md
      (lib.mkIf cfg.codex.enable {
        ".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink
          "${agentsPath}/AGENTS.md";
      })

      # Codex superpowers skills
      (lib.mkIf (cfg.codex.enable && cfg.codex.superpowersPath != null) {
        ".agents/skills/superpowers".source =
          "${cfg.codex.superpowersPath}/skills";
      })

      # Codex Ralph skill + script
      (lib.mkIf (cfg.codex.enable && ralph != null) {
        ".agents/skills/ralph".source =
          "${ralph}/skills/ralph";
        ".codex/scripts/ralph.sh".source =
          "${ralph}/ralph.sh";
      })

      # Commands/skills — Claude Code
      (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".claude/commands/${name}.md" {
          source = cmd.file;
        }
      ) commands)

      # Commands/skills — Codex (with YAML frontmatter)
      (lib.mkIf cfg.codex.enable (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".codex/prompts/${name}.md" {
          text = renderCodexPrompt name cmd;
        }
      ) commands))

      # Commands/skills — OpenCode (with YAML frontmatter)
      (lib.mkIf cfg.opencode.enable (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".config/opencode/skills/${name}/SKILL.md" {
          text = renderOpenCodeSkill name cmd;
        }
      ) commands))

      # Commands — OpenCode slash commands
      (lib.mkIf cfg.opencode.enable (lib.mapAttrs' (name: cmd:
        lib.nameValuePair ".config/opencode/command/${name}.md" {
          text = renderOpenCodeCommand name cmd;
        }
      ) commands))
    ];

    # Codex: patch a managed block in config.toml while preserving runtime state.
    home.activation.codexConfig = lib.mkIf (cfg.codex.enable && codexConfigToml != { }) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CODEX_CONFIG="${config.home.homeDirectory}/.codex/config.toml"
        MARKER_START="# BEGIN NIX MANAGED CODEX CONFIG"
        MARKER_END="# END NIX MANAGED CODEX CONFIG"
        if [ -f "$CODEX_CONFIG" ]; then
          ${pkgs.gawk}/bin/awk '
            $0 == ENVIRON["MARKER_START"] { managed=1; next }
            $0 == ENVIRON["MARKER_END"] { managed=0; next }
            /^\[mcp_servers\./ { legacy_mcp=1; next }
            legacy_mcp && /^\[/ { legacy_mcp=0 }
            !managed && !legacy_mcp { print }
          ' "$CODEX_CONFIG" > "$CODEX_CONFIG.tmp"
          printf '\n%s\n' "$MARKER_START" >> "$CODEX_CONFIG.tmp"
          cat ${codexConfigTomlFile} >> "$CODEX_CONFIG.tmp"
          printf '%s\n' "$MARKER_END" >> "$CODEX_CONFIG.tmp"
          mv "$CODEX_CONFIG.tmp" "$CODEX_CONFIG"
        else
          mkdir -p "$(dirname "$CODEX_CONFIG")"
          printf '%s\n' "$MARKER_START" > "$CODEX_CONFIG"
          cat ${codexConfigTomlFile} >> "$CODEX_CONFIG"
          printf '%s\n' "$MARKER_END" >> "$CODEX_CONFIG"
        fi
      ''
    );

    home.activation.localAgentSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      AGENTS_SKILLS_DIR="${config.home.homeDirectory}/.agents/skills"
      mkdir -p "$AGENTS_SKILLS_DIR"
      if [ -e "$AGENTS_SKILLS_DIR/local-skills" ]; then
        chmod -R u+w "$AGENTS_SKILLS_DIR/local-skills"
      fi
      rm -rf "$AGENTS_SKILLS_DIR/local-skills"
      cp -RL ${localAgentSkillsDir}/local-skills "$AGENTS_SKILLS_DIR/"
    '';
  };
}
