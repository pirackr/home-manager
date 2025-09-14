# Emacs Configuration Improvement Tasks

Generated on: 2025-01-13

This document contains a comprehensive list of tasks for improving the Emacs configuration in this Home Manager setup.

## 🔧 Configuration Issues & Bug Fixes

### High Priority
- [ ] **Fix missing marginalia dependency** - `themes.nix:34` references `marginalia` but it's not configured anywhere, causing potential errors in `all-the-icons-completion`
- [ ] **Fix flycheck/flymake conflict** - `core.nix:84` enables flycheck globally but `development.nix:38` tells eglot to stay out of flycheck, creating inconsistent syntax checking
- [ ] **Fix duplicate treesit configuration** - Tree-sitter sources are defined in both `default.nix:65-84` and `core.nix:92-96`, causing redundancy and potential conflicts
- [ ] **Fix inconsistent haskell-ts-mode setup** - `haskell.nix` lacks proper conditional loading and integration with the main emacs enable flag

### Medium Priority
- [ ] **Add missing which-key package** - `default.nix:99` calls `(which-key-mode +1)` but which-key package is not explicitly configured
- [ ] **Fix project.el package reference** - `editing.nix:20` incorrectly uses `epkgs.emacs` for project.el (which is built-in)
- [ ] **Improve apheleia initialization** - `editing.nix:149` uses `require` in `:init` instead of proper use-package configuration
- [ ] **Fix treesit-auto language configuration overlap** - Some languages are configured in both global and treesit-auto configs

## 🚀 Performance Optimizations

### Startup Performance
- [ ] **Optimize garbage collection settings** - Consolidate GC settings scattered across multiple files into a single coherent strategy
- [ ] **Add lazy loading for heavy packages** - Many packages like `dap-mode`, `treemacs`, and language modes could be deferred
- [ ] **Implement conditional package loading** - Load development packages only when needed for specific file types
- [ ] **Remove unnecessary global modes** - `global-whitespace-mode` is enabled globally which can impact performance

### Runtime Performance
- [ ] **Optimize eglot configuration** - Current eglot config disables hover provider globally, may want per-language control
- [ ] **Add eglot memory management** - Implement automatic eglot server shutdown for unused projects
- [ ] **Optimize completion backends** - Company configuration is minimal, could add performance tuning

## ✨ Missing Features & Enhancements

### Core Features
- [ ] **Add marginalia for better completion annotations** - Referenced in themes but not configured
- [ ] **Add embark for contextual actions** - Would complement vertico/consult setup
- [ ] **Add orderless for flexible completion matching** - Better completion experience
- [ ] **Add savehist configuration** - Currently enabled in prelude but not configured properly
- [ ] **Add recentf configuration** - Enabled but not properly configured with limits/cleanup

### Development Tools
- [ ] **Add dedicated LSP configurations per language** - Current eglot setup is very basic
- [ ] **Add debugging configuration** - dap-mode is enabled but not configured for any languages
- [ ] **Add code formatting per language** - Only apheleia is configured globally
- [ ] **Add language-specific snippets** - yasnippet is enabled but no snippet collections
- [ ] **Add magit workflow enhancements** - Basic magit setup, could add workflow helpers

### Editor Enhancements
- [ ] **Add window management packages** - ace-window, winner-mode, or similar
- [ ] **Add buffer management improvements** - ibuffer filters, buffer-move
- [ ] **Add file management enhancements** - dired improvements, file templates
- [ ] **Add search and navigation** - avy, ace-jump, or similar for quick navigation
- [ ] **Add multiple cursors support** - multiple-cursors or iedit

### Language Support
- [ ] **Add Rust language support** - rust-mode, rustic, or similar
- [ ] **Add JavaScript/TypeScript support** - js2-mode, typescript-mode, etc.
- [ ] **Add Docker support** - dockerfile-mode
- [ ] **Add Markdown support** - markdown-mode with proper configuration
- [ ] **Add YAML improvements** - Better YAML editing beyond basic LSP

## 🏗️ Structural Improvements

### Code Organization
- [ ] **Consolidate performance settings** - GC, memory, and startup optimizations spread across files
- [ ] **Create consistent package patterns** - Some packages use different configuration styles
- [ ] **Add configuration validation** - Ensure all referenced packages are properly defined
- [ ] **Standardize defer/lazy loading** - Inconsistent use of defer across packages

### Configuration Management
- [ ] **Add feature toggles** - Allow enabling/disabling major feature groups
- [ ] **Add per-system customization** - Different configs for macOS vs Linux where needed
- [ ] **Add user customization hooks** - Easy way to add personal overrides
- [ ] **Improve documentation** - Add more inline documentation for complex configurations

### Module Structure
- [ ] **Split large modules** - `development.nix` and `editing.nix` are getting large
- [ ] **Create language-specific modules** - Individual modules for major languages
- [ ] **Add completion module** - Separate completion-related packages from core
- [ ] **Create UI module** - Separate theming and UI packages

## 🎨 Theme and UI Improvements

### Visual Enhancements
- [ ] **Add font configuration options** - Make font settings more flexible
- [ ] **Add theme switching support** - Easy way to switch between themes
- [ ] **Improve modeline configuration** - More doom-modeline customization
- [ ] **Add dashboard/startup screen** - Replace scratch buffer with useful dashboard

### Icon and Visual Consistency
- [ ] **Audit all-the-icons usage** - Ensure consistent icon usage across packages
- [ ] **Add nerd-fonts integration** - Better integration with system nerd fonts
- [ ] **Improve treemacs theming** - Better integration with overall theme

## 📋 Testing and Quality Assurance

### Configuration Testing
- [ ] **Add configuration build tests** - Ensure config builds on both Linux and macOS
- [ ] **Add package availability tests** - Verify all referenced packages exist
- [ ] **Add startup time benchmarking** - Track configuration performance impact
- [ ] **Add error handling** - Better error handling for missing dependencies

### Documentation
- [ ] **Document keybindings** - Central documentation of all keybindings
- [ ] **Add configuration guide** - How to customize and extend the configuration
- [ ] **Document package purposes** - Why each package was chosen and its role
- [ ] **Add troubleshooting guide** - Common issues and solutions

## 📚 Learning and Exploration

### Modern Emacs Features
- [ ] **Explore built-in packages** - Use more built-in Emacs 29+ features
- [ ] **Investigate tree-sitter modes** - More comprehensive tree-sitter integration
- [ ] **Add native JSON support** - Use built-in JSON parsing where possible
- [ ] **Explore package.el alternatives** - Consider elpaca or similar

### Workflow Optimization
- [ ] **Add org-mode enhancements** - Current org setup is basic, could expand
- [ ] **Improve git workflow** - Add more magit extensions and workflows
- [ ] **Add project management** - Beyond basic project.el, add project-specific configs
- [ ] **Add session management** - Better session save/restore functionality

---

## Priority Matrix

**High Priority (Fix First):**
- Configuration bugs and errors
- Performance issues affecting daily use
- Missing critical dependencies

**Medium Priority (Enhance Experience):**
- Missing features that improve productivity
- Structural improvements for maintainability
- Better language support

**Low Priority (Future Improvements):**
- Advanced features and optimizations
- Experimental packages and workflows
- Documentation and testing infrastructure

## Implementation Strategy

1. **Phase 1**: Fix all configuration bugs and critical issues
2. **Phase 2**: Add missing core features and performance optimizations
3. **Phase 3**: Implement structural improvements and better organization
4. **Phase 4**: Add advanced features and workflow enhancements
5. **Phase 5**: Documentation, testing, and quality assurance

Each task should be implemented incrementally with testing to ensure the configuration remains stable and functional.