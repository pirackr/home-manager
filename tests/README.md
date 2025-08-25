# Home Manager Configuration Tests

This directory contains test scripts to validate your Home Manager configuration.

## Test Scripts

### `test-build.sh`
Tests that the Home Manager configuration can build successfully without errors.

**What it tests:**
- Configuration syntax is valid
- All dependencies are resolvable
- Build process completes successfully

### `test-modules.sh` 
Tests that all modules are working correctly and properly integrated.

**What it tests:**
- All module files exist
- Module syntax is valid
- Modules are properly imported in `home.nix`
- Module evaluation works

### `test-individual-modules.sh`
Tests each individual module for specific functionality and structure.

**What it tests:**
- Individual module syntax
- Module-specific configurations (git, fish, vim, emacs, hyprland)
- Module structure and content validation

### `test-vim.sh`
Tests that the vim module is configured correctly and functional.

**What it tests:**
- vim binary installation and availability
- vim-related tools (vimdiff, vimtutor) 
- vim functionality and version check
- EDITOR environment variable configuration
- vim configuration settings (line numbers, tabs, etc.)
- vim package integration

### `test-emacs.sh`
Tests that the emacs module is configured correctly and functional.

**What it tests:**
- emacs binary installation and availability
- emacs-related tools (emacsclient)
- emacs functionality and version check
- .emacs.d/init.el file generation
- init.el syntax validation
- .emacs.d directory structure
- emacs configuration loading
- EDITOR environment variable configuration (optional)
- emacs package integration

### `test-machines.sh`
Tests that the machines feature is working correctly.

**What it tests:**
- Machines directory structure
- Machine configuration files exist and are valid
- Hostname mapping works
- Machine-specific configurations are present
- Integration with main configuration

### `run-all-tests.sh`
Master test runner that executes all test scripts and provides a summary.

**What it does:**
- Runs all individual test scripts
- Tracks pass/fail status
- Provides comprehensive test summary
- Returns appropriate exit codes

## Usage

### Run all tests
```bash
./tests/run-all-tests.sh
```

### Run individual tests
```bash
./tests/test-build.sh
./tests/test-vim.sh
./tests/test-emacs.sh
./tests/test-modules.sh
./tests/test-individual-modules.sh
./tests/test-machines.sh
```

## Exit Codes
- `0`: All tests passed
- `1`: One or more tests failed

## Requirements
- `home-manager` command available in PATH
- `nix-instantiate` command available
- Standard shell utilities (`grep`, `basename`, etc.)

## Adding New Tests

To add a new test script:

1. Create a new `.sh` file in the `tests/` directory
2. Make it executable: `chmod +x tests/your-test.sh`
3. Follow the existing pattern:
   - Start with `#!/usr/bin/env bash`
   - Use `set -e` for early exit on errors
   - Provide clear output with ✅/❌ indicators
   - Return proper exit codes (0 for success, 1 for failure)
4. Add the test to the `tests` array in `run-all-tests.sh`

## Continuous Integration

These tests can be integrated into CI/CD pipelines to automatically validate configuration changes before deployment.

Example GitHub Actions workflow:
```yaml
- name: Run Home Manager Tests
  run: |
    cd $HOME/.config/home-manager
    ./tests/run-all-tests.sh
```
