# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Home Manager configuration using Nix flakes for declarative user environment management across macOS (darwin) and Linux systems. It supports two user profiles:
- `pirackr@work` (aarch64-darwin): macOS work machine at /Users/hhnguyen
- `pirackr@home` (x86_64-linux): Linux home machine at /home/pirackr

## Building and Testing

### Build Commands

Build a specific configuration:
```bash
home-manager switch --flake .#pirackr@work
home-manager switch --flake .#pirackr@home
```

Build without switching (test only):
```bash
nix build .#homeConfigurations."pirackr@work".activationPackage
nix build .#homeConfigurations."pirackr@home".activationPackage
```

Update flake inputs:
```bash
nix flake update
```

### Testing

Run all tests:
```bash
./tests/run-all-tests.sh
```

Run specific tests:
```bash
./tests/test-build.sh     # Test configuration builds successfully
./tests/test-vim.sh       # Test vim module
./tests/test-emacs.sh     # Test emacs module
./tests/test-k8s.sh       # Test Kubernetes tools
```

### Development Shell

Enter development environment:
```bash
nix develop
```

## Architecture

### Flake Structure

- **flake.nix**: Entry point defining two homeConfigurations with platform-specific settings
- **users/**: Per-user configuration files (work.nix is git-crypt encrypted)
  - `work.nix`: macOS work profile with API keys (encrypted)
  - `home.nix`: Linux home profile with nixGL wrapper and UI configuration
- **modules/**: Modular configuration split by functionality
  - `common.nix`: Shared configuration imported by all users
- **tests/**: Shell scripts to validate configuration

### Module System

All modules follow the pattern:
```nix
{
  options.modules.<name>.enable = lib.mkEnableOption "...";
  config = lib.mkIf config.modules.<name>.enable { ... };
}
```

Enable modules in user files:
```nix
modules = {
  vim.enable = true;
  emacs.enable = true;
  # ... etc
};
```

### Core Modules (in modules/)

- **common.nix**: Base packages, tmux, kitty terminal, direnv, fonts, sccache
- **git.nix**: Git configuration
- **fish.nix**: Fish shell with plugins (grc, plugin-git, theme-l)
- **vim.nix**: Vim editor setup
- **k8s.nix**: Kubernetes tools (kubectl, k9s, etc.)
- **fcitx.nix**: Input method configuration (Linux only)
- **emacs/**: Emacs configuration split into focused modules
  - `default.nix`: Main entry point with performance optimizations
  - `core.nix`: Core functionality (dired, exec-path, super-save, undo-fu, tree-sitter, jinx, flymake, which-key)
  - `completion.nix`: Completion and search (vertico, consult, company, yasnippet, anzu, fzf)
  - `editing.nix`: Editing features (move-text, treemacs, magit, forge, diff-hl, org-mode, apheleia)
  - `development.nix`: Development tools (eglot, eglot-booster, dap-mode, language modes)
  - `themes.nix`: Visual themes (catppuccin, doom-modeline, nerd-icons)
  - `languages/`: Language-specific configurations (nix, scala, python, go, terraform, yaml)
  - `prelude.el`: Basic Emacs settings loaded from file
- **agents/**: Claude Code integration
  - `AGENTS.md`: Symlinked to ~/.claude/CLAUDE.md for project-specific AI instructions
  - `skills/`: Directory for future Claude Code skills (currently unused)
- **scripts/**: Utility scripts
  - `quip2markdown`: Convert Quip documents to markdown
- **ui/**: Linux desktop environment (Hyprland-based)
  - `hyprland.nix`: Hyprland window manager
  - `gtk.nix`: GTK theme with Catppuccin
  - `mako.nix`: Notification daemon
  - `waybar.nix`: Status bar
  - `rofi.nix`: Application launcher
  - `hyprlock.nix`: Screen locker

### Package Management

Packages in common.nix are wrapped with `dontCheck` to skip test phases during local builds for faster iteration. This is a local helper function defined at the top of common.nix.

Platform-specific packages are added conditionally:
```nix
++ lib.optionals pkgs.stdenv.isLinux [ ... ]
```

### Security

- **git-crypt**: Sensitive files are encrypted (configured in .gitattributes)
- Currently encrypted: `users/work.nix` (contains API keys)
- Never commit unencrypted secrets or API keys

### Key Technologies

- **sccache**: Rust compilation cache (configured with 20G cache, auto-starts on Linux via systemd)
- **direnv**: Automatic environment loading with nix-direnv integration
- **tmux**: Terminal multiplexer with Catppuccin Frappe theme
- **kitty**: GPU-accelerated terminal with Catppuccin Frappe theme
- **Emacs daemon**: Auto-starts with user session via systemd/launchd

### Environment Variables

Set in common.nix sessionVariables:
- `EDITOR=vim`
- `RUSTC_WRAPPER=sccache` for Rust build caching
- `SCCACHE_DIR` and `SCCACHE_CACHE_SIZE`

User-specific variables go in users/*.nix (e.g., ANTHROPIC_API_KEY in work.nix).

## Common Patterns

### Adding a New Package

Add to common.nix for all users:
```nix
home.packages = (map dontCheck [
  pkgs.your-package
  ...
]);
```

Or add to specific user file (users/work.nix or users/home.nix).

### Adding a New Module

1. Create modules/yourmodule.nix with enable option pattern
2. Import in common.nix imports list
3. Enable in user files: `modules.yourmodule.enable = true;`

### macOS-Specific Configuration

The work profile (macOS) uses mac-app-util for proper application integration and sets Option key as Alt for Emacs keybindings in kitty.

### Linux-Specific Configuration

The home profile (Linux) uses:
- nixGL wrapper for OpenGL applications (kitty)
- Full UI stack (Hyprland, GTK, waybar, etc.)
- systemd services for background tasks
- xdg-portal configuration

## Nix Configuration

User-level nix.conf is generated at ~/.config/nix/nix.conf with:
- Experimental features: nix-command, flakes
- Parallelism: max-jobs = auto, cores = 0 (use all available)
