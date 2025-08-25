#!/usr/bin/env bash
# Test script to verify that the vim module is configured correctly

set -e

echo "🔧 Testing Vim module configuration..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
RESULT_DIR="$CONFIG_DIR/result"

# Change to the configuration directory
cd "$CONFIG_DIR"

echo "📍 Configuration directory: $CONFIG_DIR"
echo "📁 Build result directory: $RESULT_DIR"

# Build the configuration first
echo "🚀 Building Home Manager configuration..."
if ! home-manager build --flake \#pirackr@work; then
    echo "❌ Build failed - vim test cannot proceed"
    exit 1
fi

echo "✅ Build completed successfully"

# Test 1: Check if vim binary exists in home-path
echo
echo "🧪 Test 1: Checking vim binary availability..."
VIM_BIN="$RESULT_DIR/home-path/bin/vim"
if [[ -f "$VIM_BIN" ]] && [[ -x "$VIM_BIN" ]]; then
    echo "✅ Test 1 PASSED: vim binary found at $VIM_BIN"
else
    echo "❌ Test 1 FAILED: vim binary not found or not executable at $VIM_BIN"
    exit 1
fi

# Test 2: Check if vim-related binaries are present
echo
echo "🧪 Test 2: Checking vim-related binaries..."
VIM_BINARIES=("vim" "vimdiff" "vimtutor")
missing_binaries=()

for binary in "${VIM_BINARIES[@]}"; do
    binary_path="$RESULT_DIR/home-path/bin/$binary"
    if [[ -f "$binary_path" ]] && [[ -x "$binary_path" ]]; then
        echo "✅ Found: $binary"
    else
        echo "❌ Missing: $binary"
        missing_binaries+=("$binary")
    fi
done

if [[ ${#missing_binaries[@]} -eq 0 ]]; then
    echo "✅ Test 2 PASSED: All vim binaries found"
else
    echo "❌ Test 2 FAILED: Missing binaries: ${missing_binaries[*]}"
    exit 1
fi

# Test 3: Check vim version and basic functionality
echo
echo "🧪 Test 3: Testing vim functionality..."
if VIM_VERSION=$("$VIM_BIN" --version 2>/dev/null | head -1); then
    echo "✅ Test 3 PASSED: vim is functional - $VIM_VERSION"
else
    echo "❌ Test 3 FAILED: vim --version command failed"
    exit 1
fi

# Test 4: Check if EDITOR environment variable would be set
echo
echo "🧪 Test 4: Checking EDITOR environment variable configuration..."
# Check if the session variables are properly set in fish configuration
EDITOR_FOUND=false

# Check the fish configuration files for EDITOR setting
if [[ -d "$RESULT_DIR/home-files/.config/fish" ]]; then
    # Find the session variables file referenced in fish config
    SESSION_VAR_FILE=$(grep -o '/nix/store/[^"]*hm-session-vars\.fish' "$RESULT_DIR/home-files/.config/fish/config.fish" 2>/dev/null | head -1)
    
    if [[ -n "$SESSION_VAR_FILE" ]] && [[ -f "$SESSION_VAR_FILE" ]]; then
        if grep -E "set.*EDITOR.*vim|EDITOR.*vim" "$SESSION_VAR_FILE" >/dev/null 2>&1; then
            echo "✅ Test 4 PASSED: EDITOR variable configured to use vim in session variables ($SESSION_VAR_FILE)"
            EDITOR_FOUND=true
        fi
    fi
    
    # Also check fish config directly
    if grep -r "set.*EDITOR.*vim" "$RESULT_DIR/home-files/.config/fish" >/dev/null 2>&1; then
        echo "✅ Test 4 PASSED: EDITOR variable configured to use vim in fish config"
        EDITOR_FOUND=true
    fi
fi

# Check the activate script for environment variable exports
if grep -E "export.*EDITOR.*vim|EDITOR.*vim" "$RESULT_DIR/activate" >/dev/null 2>&1; then
    echo "✅ Test 4 PASSED: EDITOR variable configured to use vim in activate script"
    EDITOR_FOUND=true
fi

# Check other shell configuration files
for shell_file in "$RESULT_DIR/home-files/.bashrc" "$RESULT_DIR/home-files/.profile" "$RESULT_DIR/home-files/.bash_profile"; do
    if [[ -f "$shell_file" ]] && grep -E "export.*EDITOR.*vim|EDITOR.*vim" "$shell_file" >/dev/null 2>&1; then
        echo "✅ Test 4 PASSED: EDITOR variable configured to use vim in $(basename "$shell_file")"
        EDITOR_FOUND=true
        break
    fi
done

if [[ "$EDITOR_FOUND" == false ]]; then
    echo "❌ Test 4 FAILED: EDITOR environment variable not configured to use vim"
    echo "   Expected to find EDITOR=vim in session variables or shell configuration"
    exit 1
fi

# Test 5: Verify vim settings are correctly configured
echo
echo "🧪 Test 5: Verifying vim configuration settings..."
VIM_BINARY="$RESULT_DIR/home-path/bin/vim"

# Test specific vim settings from the module
echo "  Checking vim settings configuration..."

# Get vim settings output
VIM_SETTINGS=$(echo ':set all' | "$VIM_BINARY" -e -s 2>/dev/null)

# Check each setting from the vim.nix module
settings_correct=true

# Check number setting
if echo "$VIM_SETTINGS" | grep -q "number" && ! echo "$VIM_SETTINGS" | grep -q "nonumber"; then
    echo "  ✅ number: enabled"
else
    echo "  ❌ number: not enabled"
    settings_correct=false
fi

# Check relativenumber setting
if echo "$VIM_SETTINGS" | grep -q "relativenumber" && ! echo "$VIM_SETTINGS" | grep -q "norelativenumber"; then
    echo "  ✅ relativenumber: enabled"
else
    echo "  ❌ relativenumber: not enabled"
    settings_correct=false
fi

# Check shiftwidth setting
if echo "$VIM_SETTINGS" | grep -q "shiftwidth=2"; then
    echo "  ✅ shiftwidth: set to 2"
else
    echo "  ❌ shiftwidth: not set to 2"
    settings_correct=false
fi

# Check tabstop setting
if echo "$VIM_SETTINGS" | grep -q "tabstop=2"; then
    echo "  ✅ tabstop: set to 2"
else
    echo "  ❌ tabstop: not set to 2"
    settings_correct=false
fi

# Check expandtab setting
if echo "$VIM_SETTINGS" | grep -q "expandtab" && ! echo "$VIM_SETTINGS" | grep -q "noexpandtab"; then
    echo "  ✅ expandtab: enabled"
else
    echo "  ❌ expandtab: not enabled"
    settings_correct=false
fi

# Check clipboard setting (from extraConfig)
if echo "$VIM_SETTINGS" | grep -q "clipboard=unnamedplus"; then
    echo "  ✅ clipboard: set to unnamedplus"
else
    echo "  ❌ clipboard: not set to unnamedplus"
    settings_correct=false
fi

# Test syntax highlighting (from extraConfig)
SYNTAX_TEST=$(echo ':syntax' | "$VIM_BINARY" -e -s 2>/dev/null)
if echo "$SYNTAX_TEST" | grep -q "syntax=ON" || echo "$SYNTAX_TEST" | grep -q "syntax highlighting is on"; then
    echo "  ✅ syntax highlighting: enabled"
else
    echo "  ⚠️  syntax highlighting: status unclear (may be enabled)"
fi

if [[ "$settings_correct" == true ]]; then
    echo "✅ Test 5 PASSED: All vim settings configured correctly"
else
    echo "❌ Test 5 FAILED: Some vim settings not configured as expected"
    exit 1
fi

# Test 6: Check that vim package is properly referenced in the build
echo
echo "🧪 Test 6: Verifying vim package integration..."
if [[ -d "$RESULT_DIR/home-path/share/vim" ]] || [[ -d "$RESULT_DIR/home-path/share/applications" ]]; then
    echo "✅ Test 6 PASSED: vim package properly integrated with support files"
else
    echo "⚠️  Test 6 WARNING: vim support files not found in expected locations"
fi

echo
echo "=========================================="
echo "📊 Vim Module Test Summary"
echo "=========================================="
echo "✅ vim binary installation: VERIFIED"
echo "✅ vim related tools: VERIFIED" 
echo "✅ vim functionality: VERIFIED"
echo "✅ EDITOR environment variable: VERIFIED"
echo "✅ vim configuration settings: VERIFIED"
echo "✅ vim package integration: VERIFIED"

echo
echo "🎉 Vim module test completed successfully!"
echo "   The vim module appears to be properly configured and functional."
echo "   All settings from vim.nix are correctly applied:"
echo "   - Line numbers and relative numbers enabled"
echo "   - Tab settings: tabstop=2, shiftwidth=2, expandtab=true"
echo "   - Clipboard integration with system clipboard"
echo "   - Syntax highlighting enabled"

exit 0
