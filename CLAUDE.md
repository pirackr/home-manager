# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Home Manager configuration using Nix Flakes. It manages dotfiles and system configurations across multiple environments (work macOS and home Linux). The configuration is modularized for better maintainability and uses extensive custom modules.

## Architecture

### Flake Structure
- `flake.nix`: Main flake configuration with two homeConfigurations:
  - `pirackr@work` (aarch64-darwin) - macOS configuration with mac-app-util integration
  - `pirackr@home` (x86_64-linux) - Linux configuration with nixGL support
- `flake.lock`: Lockfile for dependencies
- Flake inputs:
  - nixpkgs (nixpkgs-unstable)
  - home-manager
  - flake-utils
  - nixgl (for Linux OpenGL applications)
  - mac-app-util (for macOS app integration)

### Configuration Organization

#### Top-level Directories
- `modules/`: Reusable configuration modules (all follow the enable pattern)
- `users/`: User-specific configurations
- `tests/`: Test scripts for validating configurations

#### Module Structure
- `modules/common.nix`: Shared configuration imported by both user profiles
  - Imports all other modules
  - Defines common packages, fonts, environment variables
  - Configures kitty terminal, tmux, direnv, sccache
  - Sets up Nix experimental features
  - Manages Emacs daemon service

- `modules/git.nix`: Git configuration with user settings
- `modules/fish.nix`: Fish shell with plugins (grc, plugin-git, foreign-env, theme-l)
- `modules/vim.nix`: Vim configuration with basic settings
- `modules/k8s.nix`: Kubernetes tools (kubectl, kind, kubelogin-oidc with custom wrapper)
- `modules/fcitx.nix`: Fcitx5 input method editor with Vietnamese Unikey support

#### Emacs Module Structure (`modules/emacs/`)
Highly modular Emacs configuration split into focused files:
- `default.nix`: Main emacs module coordinator with performance optimizations
- `emacs-init.nix`: Core init and package configuration
- `core.nix`: Core packages (dired, exec-path-from-shell, super-save, undo-fu, tree-sitter, jinx, flymake, which-key, editorconfig)
- `evil.nix`: Vim emulation (evil-mode, evil-collection, evil-surround, evil-commentary, evil-goggles)
- `completion.nix`: Completion frameworks (vertico, consult, company, yasnippet, anzu, fzf)
- `editing.nix`: Editing tools (move-text, treemacs, magit, forge, diff-hl, org-mode, org-roam, org-bullets, apheleia)
- `development.nix`: Development tools (eglot, eglot-booster, dap-mode)
- `themes.nix`: Visual themes (catppuccin-theme, doom-modeline, nerd-icons)
- `haskell.nix`: Haskell-specific configuration
- `languages/`: Language-specific configurations
  - `scala.nix`: Scala with metals LSP, sbt-mode, scala-ts-mode
  - `python.nix`: Python with basedpyright, poetry, yapfify, posframe
  - `go.nix`: Go with gopls, go-ts-mode
  - `nix.nix`: Nix with nil LSP
  - `terraform.nix`: Terraform with hcl-mode, terraform-mode
  - `yaml.nix`: YAML configuration

#### UI Module Structure (`modules/ui/`)
Linux-specific UI components:
- `default.nix`: UI module coordinator (enables all when `modules.ui.enable = true`)
- `gtk.nix`: GTK theme configuration
- `mako.nix`: Notification daemon
- `rofi.nix`: Application launcher
- `waybar.nix`: Status bar for Wayland
- `hyprland.nix`: Hyprland window manager configuration
- `hyprlock.nix`: Screen locker for Hyprland

#### User Configurations
- `users/home.nix`: Linux-specific configuration
- `users/work.nix`: macOS-specific configuration (encrypted with git-crypt)

### Module System Pattern
All modules use the Home Manager enable pattern:
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
./tests/test-build.sh       # Test flake builds successfully
./tests/test-vim.sh         # Test vim configuration
./tests/test-emacs.sh       # Test emacs configuration and packages
./tests/test-k8s.sh         # Test kubernetes tools
```

### Updating Dependencies
```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
nix flake update home-manager
```

### Working with Encrypted Files
```bash
# Unlock git-crypt (required before modifying users/work.nix)
git-crypt unlock

# Lock files again
git-crypt lock
```

## Key Features

### Emacs Configuration
Complex modular Emacs setup in `modules/emacs/` with extensive capabilities:

#### Core Features
- **Native Compilation**: Uses `emacs-nativecomp` for significant performance improvements
- **Performance Optimizations**:
  - Early-init optimizations (gc-cons-threshold, file-name handlers)
  - Native compilation with optimized settings
  - Command performance timer to track slow operations
  - Memory tuning for better responsiveness
- **Emacs Daemon**: Runs as a system service with `startWithUserSession = true`
- Uses Home Manager's `programs.emacs.init.usePackage` system

#### Language Server Support
- **Eglot**: Built-in LSP client with eglot-booster for enhanced performance
- **Language Servers Included**:
  - Scala: metals
  - Python: basedpyright
  - Go: gopls
  - Nix: nil and nixd
  - YAML: yaml-language-server
  - Terraform: terraform-ls
  - Haskell: HLS
- **LSP Booster**: emacs-lsp-booster for improved language server performance

#### Editor Features
- **Evil Mode**: Complete Vim emulation with evil-collection, evil-surround, evil-commentary, evil-goggles
- **Tree-sitter**: Modern syntax highlighting and parsing
- **Completion**: Vertico, Consult, Company, Yasnippet integration
- **Version Control**: Magit, Forge (GitHub integration), diff-hl
- **Project Management**: Treemacs file explorer
- **Spell Checking**: Jinx with enchant, hunspell, and dictionaries
- **Code Formatting**: Apheleia for automatic formatting
- **Debugging**: DAP mode integration

#### Org Mode & Note-taking
- **Org Mode**: Full org-mode configuration with custom TODO keywords
  - Keywords: TODO, PROJ, WIP, BLOCK | DONE, KILL
  - Custom agenda views with multi-section layout
  - Remote org files via TRAMP: `/ssh:org.pirackr.xyz:/data/org/`
- **Org Roam**: Zettelkasten-style note system
  - Roam directory: `/ssh:org.pirackr.xyz:/data/org/notes`
- **Org Bullets**: Pretty bullet points for org headings

#### Visual Configuration
- **Theme**: Catppuccin Frappe theme
- **Modeline**: Doom modeline with nerd-icons
- **Fonts**: FiraCode Nerd Font with proper icon support

### Development Tools

#### Terminal & Shell
- **Kitty Terminal**:
  - Catppuccin Frappe theme with 95% opacity
  - FiraCode Nerd Font Mono (16pt)
  - Powerline tab bar
  - NixGL wrapped on Linux for OpenGL support
- **Tmux**:
  - Catppuccin Frappe themed
  - Vi-style key bindings (keyMode = emacs in config, but uses vi-style pane navigation)
  - Mouse support enabled
  - Custom pane/window navigation shortcuts
- **Fish Shell**:
  - oh-my-fish theme-l
  - Plugins: grc, plugin-git, foreign-env
  - Custom aliases for AI tools (gemini, claude, codex, ccusage)

#### Version Control
- **Git**: Basic configuration with user-specific overrides
- **Magit**: Full-featured Git porcelain in Emacs
- **Forge**: GitHub/GitLab integration in Magit

#### Kubernetes Tools
- **kubectl**: Kubernetes CLI
- **kind**: Kubernetes in Docker
- **helm**: Package manager for Kubernetes
- **kubelogin-oidc**: OIDC authentication with custom wrapper script
  - Custom wrapper adds environment-based cache directories

#### Build & Development Acceleration
- **sccache**: Shared compilation cache for Rust/C++
  - Configured with 20GB cache size
  - Systemd service auto-starts on Linux
  - Environment variables: `RUSTC_WRAPPER`, `SCCACHE_DIR`, `SCCACHE_CACHE_SIZE`
- **direnv**: Automatic environment loading with nix-direnv integration

#### Cloud & Infrastructure Tools
- **AWS**: awscli2
- **Azure**: azure-cli
- **Cloudflare**: cloudflared tunnel client
- **Secrets Management**: doppler CLI
- **Infrastructure as Code**: Terraform with LSP support in Emacs
- **Monitoring**: Prometheus CLI tools

#### Package Managers & Languages
- **Node.js**: nodejs with npm
- **Python**: uv (fast Python package installer), poetry, cookiecutter
- **LaTeX**: texlive.combined.scheme-full (complete LaTeX distribution)

#### Utilities
- **Search & Text**: ripgrep, jq, less
- **System Monitoring**: htop, lm_sensors (Linux)
- **Network**: curl, wget, openssh
- **Nix Tools**: nix-prefetch-github, nixpkgs-fmt

### Input Method Support
- **Fcitx5**: Input method framework
  - GTK and Qt6 support
  - Vietnamese Unikey support
  - Proper environment variables (GTK_IM_MODULE, QT_IM_MODULE, etc.)

### UI & Desktop Environment (Linux Only)

#### Hyprland Ecosystem
- **Hyprland**: Modern Wayland compositor
- **Waybar**: Status bar with system information
- **Rofi**: Application launcher
- **Mako**: Notification daemon
- **Hyprlock**: Screen locker
- **GTK**: GTK theme configuration

#### Additional Linux Applications
- Firefox browser
- PCManFM file manager
- pwvucontrol (PipeWire volume control)
- wallutils for wallpaper management

### Fonts
Comprehensive font stack for multilingual and icon support:
- **Noto Fonts**: Noto Sans, Noto CJK Sans, Noto Color Emoji
- **Programming**: FiraCode Nerd Font (with ligatures)
- **Icons**: Font Awesome
- Font configuration enabled with proper emoji rendering

### Cross-Platform Support
- **macOS**:
  - Uses mac-app-util for proper .app bundle creation
  - aarch64-darwin architecture (Apple Silicon)
- **Linux**:
  - Uses nixGL for OpenGL applications
  - x86_64-linux architecture
  - Full Wayland/Hyprland desktop environment
  - Systemd user services (sccache)

### Performance Features
- **Build Optimization**: `dontCheck` wrapper skips test phases during local builds
- **Nix Configuration**:
  - Parallel builds: `max-jobs = auto`
  - CPU utilization: `cores = 0` (use all available)
  - Experimental features: nix-command, flakes

## Important Notes

### Work Configuration Security
- `users/work.nix` is encrypted with git-crypt
- Contains sensitive work-related configurations (email, work-specific packages, etc.)
- Must run `git-crypt unlock` before viewing or modifying
- Automatically locked when committed

### NixGL Integration (Linux)
- Linux configuration uses nixGL for GUI applications requiring OpenGL
- Kitty terminal is wrapped with nixGL for proper GPU acceleration
- Required for proper rendering of graphical applications from Nix on non-NixOS systems

### Remote File Access
- Org-mode files are stored remotely via TRAMP
- Main org directory: `/ssh:org.pirackr.xyz:/data/org/`
- Org-roam notes: `/ssh:org.pirackr.xyz:/data/org/notes`
- Requires SSH access to org.pirackr.xyz host

### Emacs Daemon
- Emacs runs as a user service with `services.emacs.enable = true`
- Starts automatically with user session
- Use `emacsclient` to connect to the running daemon
- Native compilation cache stored in `~/.emacs.d/var/eln-cache/`

### Build Performance
- All packages wrapped with `dontCheck` helper to skip test phases
- Reduces build time during local development
- Tests are still run during CI/CD if configured

### Sccache Configuration
- Rust/C++ compilation cache configured with 20GB limit
- Cache directory: `~/.cache/sccache`
- Systemd service on Linux ensures daemon is always running
- Check status: `sccache --show-stats`

### Kubernetes Tools
- Custom kubelogin wrapper automatically manages cache directories per environment
- Use `--environment <env>` flag to organize caches by cluster/environment
- Cache stored in `~/.kube/cache/kubelogin/<environment>/`

### Terminal Configuration
- Tmux uses `xterm-kitty` terminal type
- Catppuccin Frappe theme consistent across kitty, tmux, and emacs
- Both support powerline-style visual elements

## Module Enabling Guide

### Enabling Modules
Modules are enabled in user configuration files (`users/home.nix` or `users/work.nix`):

```nix
modules = {
  git.enable = true;
  fish.enable = true;
  vim.enable = true;
  emacs.enable = true;
  k8s.enable = true;
  fcitx.enable = true;  # Linux only
  ui.enable = true;     # Linux only - enables all UI components
};
```

### Emacs Sub-modules
Emacs modules are automatically enabled when `modules.emacs.enable = true`. Individual sub-modules (evil, haskell, languages) are organized internally and don't require separate enabling.

### UI Sub-modules
When `modules.ui.enable = true`, all UI components are enabled by default:
- gtk, mako, hyprlock, waybar, rofi, hyprland

Individual components can be disabled:
```nix
modules.ui = {
  enable = true;
  rofi.enable = false;  # Disable specific component
};
```

## File Organization Reference

### Configuration Files by Purpose

#### Entry Points
- `flake.nix` - Main flake configuration
- `users/work.nix` - macOS user config (encrypted)
- `users/home.nix` - Linux user config

#### Core Modules
- `modules/common.nix` - Shared configuration
- `modules/git.nix` - Git configuration
- `modules/fish.nix` - Fish shell
- `modules/vim.nix` - Vim editor
- `modules/k8s.nix` - Kubernetes tools
- `modules/fcitx.nix` - Input method

#### Emacs Configuration
- `modules/emacs/default.nix` - Main coordinator
- `modules/emacs/emacs-init.nix` - Init configuration
- `modules/emacs/core.nix` - Core packages
- `modules/emacs/evil.nix` - Vim emulation
- `modules/emacs/completion.nix` - Completion frameworks
- `modules/emacs/editing.nix` - Editing tools, org-mode
- `modules/emacs/development.nix` - LSP, debugging
- `modules/emacs/themes.nix` - Visual themes
- `modules/emacs/haskell.nix` - Haskell config
- `modules/emacs/languages/*.nix` - Per-language configs

#### UI Configuration (Linux)
- `modules/ui/default.nix` - UI coordinator
- `modules/ui/gtk.nix` - GTK theme
- `modules/ui/hyprland.nix` - Window manager
- `modules/ui/waybar.nix` - Status bar
- `modules/ui/rofi.nix` - App launcher
- `modules/ui/mako.nix` - Notifications
- `modules/ui/hyprlock.nix` - Screen locker

#### Testing
- `tests/run-all-tests.sh` - Run all tests
- `tests/test-build.sh` - Test flake builds
- `tests/test-vim.sh` - Test vim config
- `tests/test-emacs.sh` - Test emacs packages
- `tests/test-k8s.sh` - Test k8s tools

## Troubleshooting

### Build Issues
```bash
# Clear old generations
nix-collect-garbage -d

# Rebuild flake lock
rm flake.lock
nix flake update

# Check flake for errors
nix flake check
```

### Emacs Issues
```bash
# Check emacs daemon status
systemctl --user status emacs

# Restart emacs daemon
systemctl --user restart emacs

# View emacs logs
journalctl --user -u emacs

# Clear native compilation cache
rm -rf ~/.emacs.d/var/eln-cache/
```

### Sccache Issues
```bash
# Check sccache status
sccache --show-stats

# Clear sccache cache
sccache --stop-server
rm -rf ~/.cache/sccache
sccache --start-server
```

### Git-crypt Issues
```bash
# Check if files are encrypted
git-crypt status

# Re-lock after unlock
git-crypt lock
```

### NixGL Issues (Linux)
```bash
# If GUI apps fail to render properly
# Ensure nixGL wrapper is properly applied in configuration
# Check: modules/common.nix for nixGL wrapping examples
```

## Development Workflow Tips

### Adding New Packages
1. Add to appropriate section in `modules/common.nix`
2. Wrap with `dontCheck` if it's in the mapped list
3. Use `lib.optionals pkgs.stdenv.isLinux` for Linux-only packages
4. Build and test: `home-manager build --flake .`

### Adding New Modules
1. Create new file in `modules/` (e.g., `modules/newmodule.nix`)
2. Follow the enable pattern (see Module System Pattern above)
3. Import in `modules/common.nix`
4. Enable in user config (`users/home.nix` or `users/work.nix`)
5. Add tests in `tests/test-newmodule.sh`

### Adding Emacs Packages
1. Identify appropriate module (core, completion, editing, development, themes)
2. Add to that module's usePackage configuration
3. Or create new language module in `modules/emacs/languages/`
4. Test with `./tests/test-emacs.sh`

### Modifying User Configs
- For Linux: Edit `users/home.nix` directly
- For macOS: Run `git-crypt unlock`, edit `users/work.nix`, commit (auto-locks)

## State Version
- Current state version: `24.11`
- Do not change unless migrating to a new Home Manager release
- Check Home Manager release notes before updating