# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Home Manager configuration using Nix Flakes. It manages dotfiles and system configurations across multiple environments (work macOS and home Linux). The configuration is modularized for better maintainability.

## Architecture

### Flake Structure
- `flake.nix`: Main flake configuration with two homeConfigurations:
  - `pirackr@work` (aarch64-darwin) - macOS configuration
  - `pirackr@home` (x86_64-linux) - Linux configuration
- `flake.lock`: Lockfile for dependencies

### Configuration Organization
- `modules/`: Reusable configuration modules
  - `common.nix`: Shared configuration imported by both user profiles
  - Individual modules: `git.nix`, `fish.nix`, `vim.nix`, `hyprland.nix`, `emacs/`, `k8s.nix`, `fcitx.nix`
- `users/`: User-specific configurations
  - `home.nix`: Linux-specific configuration
  - `work.nix`: macOS-specific configuration (encrypted with git-crypt)

### Module System
Modules use the Home Manager enable pattern:
```nix
options.modules.<name> = {
  enable = lib.mkEnableOption "<name> configuration";
};

config = lib.mkIf config.modules.<name>.enable {
  # module configuration
};
```

## Common Development Tasks

### Building and Switching Configuration
```bash
# Build and switch to new configuration
home-manager switch --flake .

# Build without switching (dry run)
home-manager build --flake .

# For specific configuration
home-manager switch --flake .#pirackr@home
home-manager switch --flake .#pirackr@work
```

### Testing Configuration
```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific tests
./tests/test-build.sh
./tests/test-vim.sh
./tests/test-emacs.sh
```

### Updating Dependencies
```bash
# Update flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

## Key Features

### Emacs Configuration
- Complex modular Emacs setup in `modules/emacs/`
- Uses Home Manager's `programs.emacs.init.usePackage` system
- **Language Server Support**: Uses Eglot (built-in LSP client) with eglot-booster for enhanced performance
- **Language Support**: Scala (metals), Python (basedpyright), Go, Nix (nil), Terraform, Haskell (HLS)
- Includes evil mode, tree-sitter, and comprehensive language-specific configurations
- Performance optimizations: eglot-booster, memory tuning, flymake integration

### Development Tools
- Multiple editor support (Emacs, Vim)
- Terminal: Kitty with Catppuccin theme
- Shell: Fish with custom configuration
- Git configuration with user-specific overrides
- Kubernetes tools (kubectl, etc.)
- Input method support (fcitx)

### Cross-Platform Support
- macOS: Uses mac-app-util and specific package configurations
- Linux: Uses nixGL for OpenGL applications, Hyprland window manager

## Important Notes

### Work Configuration Security
- `users/work.nix` is encrypted with git-crypt
- Contains sensitive work-related configurations
- Requires git-crypt unlock to modify

### NixGL Integration
- Linux configuration uses nixGL for GUI applications
- Kitty terminal is wrapped with nixGL for proper OpenGL support

### Claude Code Integration
- Includes `claude-code` package in common packages
- Uses the official nix flake: `github:sadjow/claude-code-nix`