{ config, pkgs, lib, ... }:

let
  cfg = config.modules.rq-cli;

  rq-cli = pkgs.rustPlatform.buildRustPackage {
    pname = "rq-cli";
    version = "0.3.0";

    src = cfg.src;

    cargoHash = "sha256-cQCfUOiEgdlJlTpAFFfdLaPOzePv7M8Q1L32q2EOAwY=";

    buildInputs = lib.optionals pkgs.stdenv.isDarwin [
      pkgs.apple-sdk_15
    ];

    meta = {
      description = "A Rust CLI wrapping the Quip Automation API";
    };
  };

in
{
  options.modules.rq-cli = {
    enable = lib.mkEnableOption "rq-cli - Quip API CLI";

    src = lib.mkOption {
      type = lib.types.path;
      description = "Source for rq-cli (e.g. builtins.fetchGit { ... })";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ rq-cli ];

    # Register the quip skill from rq-cli with the agents module
    modules.agents.commands.quip = {
      description = "Work with Quip documents";
      file = "${cfg.src}/skills/quip.md";
    };
  };
}
