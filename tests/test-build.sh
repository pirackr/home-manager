#!/usr/bin/env bash
# Test script to verify that the home-manager configuration can build successfully

set -e

echo "🔨 Testing Home Manager configuration build..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Change to the configuration directory
cd "$CONFIG_DIR"

echo "📍 Configuration directory: $CONFIG_DIR"

# Test if the configuration can build without errors
echo "🚀 Running home-manager build..."
if home-manager build; then
    echo "✅ Build test PASSED: Configuration builds successfully"
    exit 0
else
    echo "❌ Build test FAILED: Configuration failed to build"
    exit 1
fi
