#!/usr/bin/env bash
# Master test runner - runs all test scripts

set -e

echo "🚀 Running Home Manager Configuration Tests"
echo "=========================================="

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test scripts to run
tests=(
    "test-build.sh"
    "test-vim.sh"
    "test-emacs.sh"
)

# Track results
passed_tests=()
failed_tests=()

# Run each test
for test in "${tests[@]}"; do
    test_path="$SCRIPT_DIR/$test"
    test_name=$(basename "$test" .sh)
    
    echo
    echo "🧪 Running: $test_name"
    echo "----------------------------------------"
    
    if [[ -f "$test_path" ]] && [[ -x "$test_path" ]]; then
        if "$test_path"; then
            passed_tests+=("$test_name")
            echo "✅ $test_name: PASSED"
        else
            failed_tests+=("$test_name")
            echo "❌ $test_name: FAILED"
        fi
    else
        echo "⚠️  Test script not found or not executable: $test_path"
        failed_tests+=("$test_name")
    fi
done

echo
echo "=========================================="
echo "📊 Test Results Summary"
echo "=========================================="

echo "✅ Passed (${#passed_tests[@]}): ${passed_tests[*]}"
if [[ ${#failed_tests[@]} -gt 0 ]]; then
    echo "❌ Failed (${#failed_tests[@]}): ${failed_tests[*]}"
else
    echo "❌ Failed: None"
fi

echo
if [[ ${#failed_tests[@]} -eq 0 ]]; then
    echo "🎉 All tests PASSED! Your Home Manager configuration is working correctly."
    exit 0
else
    echo "💥 Some tests FAILED. Please check the output above for details."
    exit 1
fi
