{ config, lib, pkgs, ... }:

let
  # Base path for agents module (for runtime symlinks)
  agentsPath = "${config.home.homeDirectory}/.config/home-manager/modules/agents";

  # Manual skill links (simpler than auto-discovery with git submodules)
  allSkillLinks = {
    # Placeholder for future skills
  };
in
{
  options.modules.agents = {
    enable = lib.mkEnableOption "agents configuration and skills";
  };

  config = lib.mkIf config.modules.agents.enable {
    # Link AGENTS.md and all skills
    home.file = lib.mkMerge [
      {
        # Claude Code instructions (merged personal guidelines + project docs)
        ".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink
          "${agentsPath}/AGENTS.md";
      }
      allSkillLinks
    ];
  };
}
