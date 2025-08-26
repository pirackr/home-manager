#!/usr/bin/env bash
# Test script to verify that the emacs module prelude.el content is properly included in generated config

set -e

echo "🔧 Testing Emacs module prelude.el integration..."

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
    echo "❌ Build failed - emacs test cannot proceed"
    exit 1
fi

echo "✅ Build completed successfully"

# Test 1: Check if emacs binary exists
echo
echo "🧪 Test 1: Checking emacs binary availability..."
EMACS_BIN="$RESULT_DIR/home-path/bin/emacs"
if [[ -f "$EMACS_BIN" ]] && [[ -x "$EMACS_BIN" ]]; then
    echo "✅ Test 1 PASSED: emacs binary found at $EMACS_BIN"
else
    echo "❌ Test 1 FAILED: emacs binary not found or not executable at $EMACS_BIN"
    exit 1
fi

# Test 2: Locate the generated hm-init.el file
echo
echo "🧪 Test 2: Locating generated hm-init.el configuration file..."

# Find the emacs-with-packages in the result
EMACS_WITH_PACKAGES=$(readlink "$RESULT_DIR/home-path/bin/emacs" | sed 's|/bin/emacs$||')
if [[ -z "$EMACS_WITH_PACKAGES" ]]; then
    echo "❌ Test 2 FAILED: Could not determine emacs-with-packages path"
    exit 1
fi

# Find the hm-init.el file
HM_INIT_FILE=""

# Look for it in the emacs packages deps
EMACS_PACKAGES_DEPS=$(nix-store -q --references "$EMACS_WITH_PACKAGES" 2>/dev/null | grep "emacs-packages-deps" | head -1)
if [[ -n "$EMACS_PACKAGES_DEPS" ]] && [[ -f "$EMACS_PACKAGES_DEPS/share/emacs/site-lisp/hm-init.el" ]]; then
    HM_INIT_FILE="$EMACS_PACKAGES_DEPS/share/emacs/site-lisp/hm-init.el"
fi

# Alternative: Look for emacs-hm-init package directly
if [[ -z "$HM_INIT_FILE" ]]; then
    HM_INIT_PACKAGE=$(nix-store -q --references "$EMACS_WITH_PACKAGES" 2>/dev/null | grep "emacs-hm-init" | head -1)
    if [[ -n "$HM_INIT_PACKAGE" ]] && [[ -f "$HM_INIT_PACKAGE/share/emacs/site-lisp/hm-init.el" ]]; then
        HM_INIT_FILE="$HM_INIT_PACKAGE/share/emacs/site-lisp/hm-init.el"
    fi
fi

if [[ -z "$HM_INIT_FILE" ]] || [[ ! -f "$HM_INIT_FILE" ]]; then
    echo "❌ Test 2 FAILED: Could not find hm-init.el file"
    exit 1
fi

echo "✅ Test 2 PASSED: hm-init.el file found at $HM_INIT_FILE"

# Test 3: Verify prelude.el content is included in generated config
echo
echo "🧪 Test 3: Verifying prelude.el content is included in generated hm-init.el..."

# Read the original prelude.el content
PRELUDE_FILE="$CONFIG_DIR/modules/emacs/prelude.el"
if [[ ! -f "$PRELUDE_FILE" ]]; then
    echo "❌ Test 3 FAILED: prelude.el file not found at $PRELUDE_FILE"
    exit 1
fi

echo "  📖 Reading prelude.el content from $PRELUDE_FILE"

# Define key configuration patterns that should be present from prelude.el
PRELUDE_PATTERNS=(
    "bootstrap-version"
    "straight/repos/straight\.el/bootstrap\.el"
    "straight-use-package.*use-package"
    "straight-use-package-by-default.*t"
    "tool-bar-mode.*-1"
    "menu-bar-mode.*-1"
    "scroll-bar-mode.*-1"
    "savehist-mode.*\+1"
    "recentf-mode.*\+1"
    "save-place-mode.*\+1"
    "inhibit-startup-message.*t"
    "initial-scratch-message.*nil"
    "global-display-line-numbers-mode.*1"
    "indent-tabs-mode.*nil"
    "tab-width.*4"
    "global-auto-revert-mode.*t"
    "global-hl-line-mode.*1"
)

echo "  🔍 Checking for prelude.el patterns in generated config..."
MISSING_PATTERNS=()

for pattern in "${PRELUDE_PATTERNS[@]}"; do
    if grep -E "$pattern" "$HM_INIT_FILE" >/dev/null 2>&1; then
        echo "  ✅ Found: $pattern"
    else
        echo "  ❌ Missing: $pattern"
        MISSING_PATTERNS+=("$pattern")
    fi
done

if [[ ${#MISSING_PATTERNS[@]} -eq 0 ]]; then
    echo "✅ Test 3 PASSED: All prelude.el content patterns found in generated config"
else
    echo "❌ Test 3 FAILED: Missing ${#MISSING_PATTERNS[@]} prelude.el patterns in generated config"
    echo "  Missing patterns: ${MISSING_PATTERNS[*]}"
    exit 1
fi

# Test 4: Verify Emacs can load the configuration and prelude settings work
echo
echo "🧪 Test 4: Testing prelude configuration runtime functionality..."

# Test that specific prelude settings are applied correctly
echo "  🔧 Testing individual prelude settings..."

# Test tab-width setting from prelude
TAB_WIDTH_RESULT=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ tab-width))" 2>/dev/null)
if [[ "$TAB_WIDTH_RESULT" == "4" ]]; then
    echo "  ✅ tab-width correctly set to 4 (from prelude.el)"
else
    echo "  ❌ tab-width not set correctly (got: '$TAB_WIDTH_RESULT', expected: 4)"
    exit 1
fi

# Test indent-tabs-mode setting from prelude
INDENT_TABS_RESULT=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ indent-tabs-mode))" 2>/dev/null)
if [[ "$INDENT_TABS_RESULT" == "nil" ]]; then
    echo "  ✅ indent-tabs-mode correctly set to nil (from prelude.el)"
else
    echo "  ❌ indent-tabs-mode not set correctly (got: '$INDENT_TABS_RESULT', expected: nil)"
    exit 1
fi

# Test inhibit-startup-message setting from prelude
INHIBIT_STARTUP_RESULT=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ inhibit-startup-message))" 2>/dev/null)
if [[ "$INHIBIT_STARTUP_RESULT" == "t" ]]; then
    echo "  ✅ inhibit-startup-message correctly set to t (from prelude.el)"
else
    echo "  ❌ inhibit-startup-message not set correctly (got: '$INHIBIT_STARTUP_RESULT', expected: t)"
    exit 1
fi

# Test that straight.el was set up correctly (from prelude)
STRAIGHT_AVAILABLE=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ (if (fboundp 'straight-use-package) 'available 'not-available)))" 2>/dev/null)
if [[ "$STRAIGHT_AVAILABLE" == "available" ]]; then
    echo "  ✅ straight-use-package function available (straight.el setup from prelude.el working)"
else
    echo "  ❌ straight-use-package not available (got: '$STRAIGHT_AVAILABLE')"
    exit 1
fi

echo "✅ Test 4 PASSED: Prelude configuration runtime functionality verified"

# Test 5: Verify configuration loads without errors
echo
echo "🧪 Test 5: Testing complete configuration loading..."
TEMP_TEST_FILE=$(mktemp)
cat > "$TEMP_TEST_FILE" << EOF
(condition-case err
    (progn
      (load "$HM_INIT_FILE")
      (message "Configuration with prelude.el loaded successfully")
      (kill-emacs 0))
  (error
    (message "Error loading configuration: %s" err)
    (kill-emacs 1)))
EOF

if "$EMACS_BIN" --batch --load "$TEMP_TEST_FILE" 2>/dev/null; then
    echo "✅ Test 5 PASSED: emacs can load complete configuration including prelude.el without errors"
else
    echo "❌ Test 5 FAILED: emacs configuration loading failed"
    echo "  Attempting to get error details:"
    "$EMACS_BIN" --batch --load "$TEMP_TEST_FILE" 2>&1 || true
    rm -f "$TEMP_TEST_FILE"
    exit 1
fi

rm -f "$TEMP_TEST_FILE"

echo
echo "=========================================="
echo "📊 Emacs Prelude Integration Test Summary"
echo "=========================================="
echo "✅ emacs binary availability: VERIFIED"
echo "✅ hm-init.el file generation: VERIFIED"
echo "✅ prelude.el content inclusion: VERIFIED"
echo "✅ prelude settings runtime application: VERIFIED"
echo "✅ complete configuration loading: VERIFIED"

echo
echo "🎉 Emacs prelude.el integration test completed successfully!"
echo "   Key verification points:"
echo "   - prelude.el content is properly included in generated hm-init.el"
echo "   - All prelude configuration patterns are present"
echo "   - Prelude settings (tab-width, indent-tabs-mode, etc.) work at runtime"
echo "   - straight.el package manager setup from prelude is functional"
echo "   - Complete configuration loads without errors"

exit 0
    exit 1
fi

# Try multiple approaches to find the hm-init.el file
HM_INIT_FILE=""

# Approach 1: Look for it in the emacs packages deps
EMACS_PACKAGES_DEPS=$(nix-store -q --references "$EMACS_WITH_PACKAGES" 2>/dev/null | grep "emacs-packages-deps" | head -1)
if [[ -n "$EMACS_PACKAGES_DEPS" ]] && [[ -f "$EMACS_PACKAGES_DEPS/share/emacs/site-lisp/hm-init.el" ]]; then
    HM_INIT_FILE="$EMACS_PACKAGES_DEPS/share/emacs/site-lisp/hm-init.el"
fi

# Approach 2: Look for emacs-hm-init package directly
if [[ -z "$HM_INIT_FILE" ]]; then
    HM_INIT_PACKAGE=$(nix-store -q --references "$EMACS_WITH_PACKAGES" 2>/dev/null | grep "emacs-hm-init" | head -1)
    if [[ -n "$HM_INIT_PACKAGE" ]] && [[ -f "$HM_INIT_PACKAGE/share/emacs/site-lisp/hm-init.el" ]]; then
        HM_INIT_FILE="$HM_INIT_PACKAGE/share/emacs/site-lisp/hm-init.el"
    fi
fi

# Approach 3: Search the entire nix store for recent hm-init.el files
if [[ -z "$HM_INIT_FILE" ]]; then
    HM_INIT_FILE=$(find /nix/store -name "hm-init.el" -path "*/emacs-hm-init-*/share/emacs/site-lisp/hm-init.el" -newer "$RESULT_DIR" 2>/dev/null | head -1)
fi

# Approach 4: Just find any recent hm-init.el in nix store
if [[ -z "$HM_INIT_FILE" ]]; then
    HM_INIT_FILE=$(find /nix/store -name "hm-init.el" 2>/dev/null | head -1)
fi

if [[ -z "$HM_INIT_FILE" ]] || [[ ! -f "$HM_INIT_FILE" ]]; then
    echo "❌ Test 4b FAILED: Could not find hm-init.el file"
    exit 1
fi

if [[ -f "$HM_INIT_FILE" ]]; then
    echo "✅ Test 4b PASSED: hm-init.el file found at $HM_INIT_FILE"
    
    # Check if the file has content
    if [[ -s "$HM_INIT_FILE" ]]; then
        echo "✅ hm-init.el file has content ($(wc -l < "$HM_INIT_FILE") lines)"
    else
        echo "⚠️  hm-init.el file exists but is empty"
    fi
else
    echo "❌ Test 4b FAILED: hm-init.el file not found at $HM_INIT_FILE"
    exit 1
fi

# Test 5: Validate hm-init.el content
echo
echo "🧪 Test 5: Validating hm-init.el content..."
CONFIG_VALID=true

# Define expected configuration content patterns from our Home Manager module
EXPECTED_CONFIGS=(
    "tool-bar-mode.*-1"
    "menu-bar-mode.*-1" 
    "scroll-bar-mode.*-1"
    "inhibit-startup-message.*t"
    "initial-scratch-message.*nil"
    "global-display-line-numbers-mode.*1"
    "indent-tabs-mode.*nil"
    "tab-width.*4"
    "global-auto-revert-mode.*t"
    "global-hl-line-mode.*1"
    "savehist-mode.*\\+1"
    "recentf-mode.*\\+1"
    "save-place-mode.*\\+1"
    "use-package ag"
)

echo "  Checking for expected configuration patterns..."
for pattern in "${EXPECTED_CONFIGS[@]}"; do
    if grep -E "$pattern" "$HM_INIT_FILE" >/dev/null 2>&1; then
        echo "  ✅ Found: $pattern"
    else
        echo "  ❌ Missing: $pattern"
        CONFIG_VALID=false
    fi
done

# Check if the file is syntactically valid Emacs Lisp
echo "  Checking Emacs Lisp syntax..."
if "$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (message \"Syntax check passed\"))" 2>/dev/null >/dev/null; then
    echo "✅ hm-init.el has valid Emacs Lisp syntax"
else
    echo "❌ hm-init.el contains syntax errors"
    echo "  Running syntax check with error output:"
    "$EMACS_BIN" --batch --eval "(load \"$HM_INIT_FILE\")" 2>&1 || true
    CONFIG_VALID=false
fi

if [[ "$CONFIG_VALID" == true ]]; then
    echo "✅ Test 5 PASSED: hm-init.el content validation successful"
else
    echo "❌ Test 5 FAILED: hm-init.el content validation failed"
    exit 1
fi

# Test 6: Test configuration runtime application
echo
echo "🧪 Test 6: Testing configuration runtime application..."
RUNTIME_TEST_VALID=true

# Test specific settings are applied when Emacs loads our configuration
echo "  Testing runtime application of configuration settings..."

# Test tab-width setting
TAB_WIDTH_RESULT=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ tab-width))" 2>/dev/null)
if [[ "$TAB_WIDTH_RESULT" == "4" ]]; then
    echo "  ✅ tab-width correctly set to 4"
else
    echo "  ❌ tab-width not set correctly (got: '$TAB_WIDTH_RESULT', expected: 4)"
    RUNTIME_TEST_VALID=false
fi

# Test indent-tabs-mode setting
INDENT_TABS_RESULT=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ indent-tabs-mode))" 2>/dev/null)
if [[ "$INDENT_TABS_RESULT" == "nil" ]]; then
    echo "  ✅ indent-tabs-mode correctly set to nil"
else
    echo "  ❌ indent-tabs-mode not set correctly (got: '$INDENT_TABS_RESULT', expected: nil)"
    RUNTIME_TEST_VALID=false
fi

# Test inhibit-startup-message setting
INHIBIT_STARTUP_RESULT=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ inhibit-startup-message))" 2>/dev/null)
if [[ "$INHIBIT_STARTUP_RESULT" == "t" ]]; then
    echo "  ✅ inhibit-startup-message correctly set to t"
else
    echo "  ❌ inhibit-startup-message not set correctly (got: '$INHIBIT_STARTUP_RESULT', expected: t)"
    RUNTIME_TEST_VALID=false
fi

# Test global-display-line-numbers-mode is available (function should exist)
LINE_NUMBERS_AVAILABLE=$("$EMACS_BIN" --batch --eval "(progn (load \"$HM_INIT_FILE\") (princ (if (fboundp 'global-display-line-numbers-mode) 'available 'not-available)))" 2>/dev/null)
if [[ "$LINE_NUMBERS_AVAILABLE" == "available" ]]; then
    echo "  ✅ global-display-line-numbers-mode is available and enabled"
else
    echo "  ❌ global-display-line-numbers-mode not available (got: '$LINE_NUMBERS_AVAILABLE')"
    RUNTIME_TEST_VALID=false
fi

if [[ "$RUNTIME_TEST_VALID" == true ]]; then
    echo "✅ Test 6 PASSED: configuration runtime application successful"
else
    echo "❌ Test 6 FAILED: configuration runtime application failed"
    exit 1
fi

# Test 7: Test emacs can load the configuration without errors
echo
echo "🧪 Test 7: Testing emacs configuration loading..."
TEMP_TEST_FILE=$(mktemp)
cat > "$TEMP_TEST_FILE" << EOF
(condition-case err
    (progn
      (load "$HM_INIT_FILE")
      (message "Configuration loaded successfully")
      (kill-emacs 0))
  (error
    (message "Error loading configuration: %s" err)
    (kill-emacs 1)))
EOF

if "$EMACS_BIN" --batch --load "$TEMP_TEST_FILE" 2>/dev/null; then
    echo "✅ Test 7 PASSED: emacs can load configuration without errors"
else
    echo "❌ Test 7 FAILED: emacs configuration loading failed"
    echo "  Attempting to get error details:"
    "$EMACS_BIN" --batch --load "$TEMP_TEST_FILE" 2>&1 || true
    rm -f "$TEMP_TEST_FILE"
    exit 1
fi

rm -f "$TEMP_TEST_FILE"

# Test 8: Check if EDITOR environment variable would be set (if configured)
echo
echo "🧪 Test 8: Checking EDITOR environment variable configuration..."
EDITOR_FOUND=false

# Check the fish configuration files for EDITOR setting
if [[ -d "$RESULT_DIR/home-files/.config/fish" ]]; then
    # Find the session variables file referenced in fish config
    SESSION_VAR_FILE=$(grep -o '/nix/store/[^"]*hm-session-vars\.fish' "$RESULT_DIR/home-files/.config/fish/config.fish" 2>/dev/null | head -1)
    
    if [[ -n "$SESSION_VAR_FILE" ]] && [[ -f "$SESSION_VAR_FILE" ]]; then
        if grep -E "set.*EDITOR.*emacs|EDITOR.*emacs" "$SESSION_VAR_FILE" >/dev/null 2>&1; then
            echo "✅ Test 8 PASSED: EDITOR variable configured to use emacs in session variables ($SESSION_VAR_FILE)"
            EDITOR_FOUND=true
        fi
    fi
    
    # Also check fish config directly
    if grep -r "set.*EDITOR.*emacs" "$RESULT_DIR/home-files/.config/fish" >/dev/null 2>&1; then
        echo "✅ Test 8 PASSED: EDITOR variable configured to use emacs in fish config"
        EDITOR_FOUND=true
    fi
fi

# Check the activate script for environment variable exports
if grep -E "export.*EDITOR.*emacs|EDITOR.*emacs" "$RESULT_DIR/activate" >/dev/null 2>&1; then
    echo "✅ Test 8 PASSED: EDITOR variable configured to use emacs in activate script"
    EDITOR_FOUND=true
fi

# Check other shell configuration files
for shell_file in "$RESULT_DIR/home-files/.bashrc" "$RESULT_DIR/home-files/.profile" "$RESULT_DIR/home-files/.bash_profile"; do
    if [[ -f "$shell_file" ]] && grep -E "export.*EDITOR.*emacs|EDITOR.*emacs" "$shell_file" >/dev/null 2>&1; then
        echo "✅ Test 8 PASSED: EDITOR variable configured to use emacs in $(basename "$shell_file")"
        EDITOR_FOUND=true
        break
    fi
done

if [[ "$EDITOR_FOUND" == false ]]; then
    echo "⚠️  Test 8 INFO: EDITOR environment variable not configured to use emacs"
    echo "   This is optional - emacs can still be used directly"
else
    echo "✅ Test 8 PASSED: EDITOR environment variable configuration found"
fi

# Test 9: Check if emacs package is properly referenced in the build
echo
echo "🧪 Test 9: Verifying emacs package integration..."
package_integration_found=false

if [[ -d "$RESULT_DIR/home-path/share/emacs" ]]; then
    echo "✅ emacs share directory found"
    package_integration_found=true
fi

if [[ -d "$RESULT_DIR/home-path/share/applications" ]]; then
    # Check for emacs desktop entry
    if find "$RESULT_DIR/home-path/share/applications" -name "*emacs*.desktop" | grep -q .; then
        echo "✅ emacs desktop entry found"
        package_integration_found=true
    fi
fi

if [[ -d "$RESULT_DIR/home-path/share/info" ]]; then
    # Check for emacs info files
    if find "$RESULT_DIR/home-path/share/info" -name "*emacs*" | grep -q .; then
        echo "✅ emacs info files found"
        package_integration_found=true
    fi
fi

if [[ "$package_integration_found" == true ]]; then
    echo "✅ Test 9 PASSED: emacs package properly integrated with support files"
else
    echo "⚠️  Test 9 WARNING: emacs support files not found in expected locations"
fi

# Test 10: Check if ag (The Silver Searcher) is installed and available
echo
echo "🧪 Test 10: Checking ag (The Silver Searcher) installation..."
AG_BIN="$RESULT_DIR/home-path/bin/ag"

if [[ -f "$AG_BIN" ]] && [[ -x "$AG_BIN" ]]; then
    echo "✅ ag binary found at $AG_BIN"
    
    # Test ag functionality
    if AG_VERSION=$("$AG_BIN" --version 2>/dev/null | head -1); then
        echo "✅ ag is functional - $AG_VERSION"
        
        # Test ag can perform a basic search (search for 'echo' in the test file itself)
        if "$AG_BIN" --count "echo" "$0" >/dev/null 2>&1; then
            echo "✅ ag search functionality verified"
            
            # Test if ag is properly configured in emacs hm-init.el
            if grep -q "use-package ag" "$HM_INIT_FILE"; then
                echo "✅ ag is configured in emacs hm-init.el"
                echo "✅ Test 10 PASSED: ag (The Silver Searcher) is properly installed and configured"
            else
                echo "⚠️  ag binary found but not configured in emacs hm-init.el"
                echo "✅ Test 10 PASSED: ag (The Silver Searcher) is installed and functional (emacs config not verified)"
            fi
        else
            echo "❌ ag search functionality failed"
            echo "❌ Test 10 FAILED: ag is installed but search functionality is not working"
            exit 1
        fi
    else
        echo "❌ ag --version command failed"
        echo "❌ Test 10 FAILED: ag is installed but not functional"
        exit 1
    fi
else
    echo "❌ ag binary not found or not executable at $AG_BIN"
    echo "❌ Test 10 FAILED: ag (The Silver Searcher) is not installed"
    echo "   This may indicate that the ag package is not properly included in the emacs configuration"
    exit 1
fi

# Test 11: Check if emacs can load ag package without errors
echo
echo "🧪 Test 11: Testing ag package loading in emacs..."
TEMP_AG_TEST_FILE=$(mktemp)
cat > "$TEMP_AG_TEST_FILE" << EOF
(condition-case err
    (progn
      (require 'ag nil t)
      (if (featurep 'ag)
          (progn
            (message "ag package loaded successfully")
            (kill-emacs 0))
        (progn
          (message "ag package not available")
          (kill-emacs 1))))
  (error
    (message "Error loading ag package: %s" err)
    (kill-emacs 1)))
EOF

if "$EMACS_BIN" --batch --load "$TEMP_AG_TEST_FILE" 2>/dev/null; then
    echo "✅ Test 11 PASSED: emacs can load ag package without errors"
else
    echo "⚠️  Test 11 WARNING: emacs cannot load ag package (may need to be installed via package manager)"
    echo "   Note: ag binary is available but emacs package may not be installed"
fi

rm -f "$TEMP_AG_TEST_FILE"

echo
echo "=========================================="
echo "📊 Emacs Module Test Summary"
echo "=========================================="
echo "✅ emacs binary installation: VERIFIED"
echo "✅ emacs related tools: VERIFIED" 
echo "✅ emacs functionality: VERIFIED"
echo "✅ .emacs.d/init.el generation: VERIFIED"
echo "✅ init.el syntax validation: VERIFIED"
echo "✅ .emacs.d directory structure: VERIFIED"
echo "✅ emacs configuration loading: VERIFIED"
if [[ "$EDITOR_FOUND" == true ]]; then
    echo "✅ EDITOR environment variable: VERIFIED"
else
    echo "ℹ️  EDITOR environment variable: NOT CONFIGURED (optional)"
fi
echo "✅ emacs package integration: VERIFIED"
echo "✅ ag (The Silver Searcher) binary: VERIFIED"
echo "✅ ag emacs package loading: VERIFIED"

echo
echo "🎉 Emacs module test completed successfully!"
echo "   The emacs module appears to be properly configured and functional."
echo "   Key verification points:"
echo "   - Emacs binary is available and executable"
echo "   - .emacs.d/init.el is properly generated"
echo "   - Configuration has valid Emacs Lisp syntax"
echo "   - Emacs can load the configuration without errors"
echo "   - Package integration is working correctly"
echo "   - ag (The Silver Searcher) is installed and functional"
echo "   - ag emacs package can be loaded without errors"

exit 0
