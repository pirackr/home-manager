#!/usr/bin/env bash

set -e

echo "Testing k8s module..."

# Build the configuration first
echo "Building Home Manager configuration..."
home-manager build --flake .#"pirackr@work"

# Check if the tools are installed and accessible
echo "Checking if k8s tools are installed..."

# Test kind
if command -v kind &> /dev/null; then
    echo "✓ kind is installed"
    kind version
else
    echo "✗ kind is not installed or not in PATH"
    exit 1
fi

# Test kubectl
if command -v kubectl &> /dev/null; then
    echo "✓ kubectl is installed"
    kubectl version --client
else
    echo "✗ kubectl is not installed or not in PATH"
    exit 1
fi

# Test kubelogin (should be our wrapper script)
if command -v kubelogin &> /dev/null; then
    echo "✓ kubelogin is installed"
    
    # Test that our wrapper script is working
    echo "Testing kubelogin wrapper script..."
    
    # Check if it's our wrapper by testing the --help output
    kubelogin_help=$(kubelogin --help 2>&1 || true)
    
    if echo "$kubelogin_help" | grep -q "azure active directory"; then
        echo "✓ kubelogin wrapper is working and calling the real kubelogin"
    else
        echo "✗ kubelogin wrapper might not be working correctly"
        echo "Output: $kubelogin_help"
        exit 1
    fi
    
    # Test that we can find the homebrew version of kubelogin when PATH is modified
    CLEANED_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/nix/store' | paste -sd ':' -)
    REAL_KUBELOGIN=$(PATH="$CLEANED_PATH" command -v kubelogin)
    
    if [[ -n "$REAL_KUBELOGIN" ]]; then
        echo "✓ Real kubelogin is accessible at: $REAL_KUBELOGIN"
    else
        echo "✗ Real kubelogin is not accessible"
        exit 1
    fi
    
else
    echo "✗ kubelogin is not installed or not in PATH"
    exit 1
fi

echo "✓ All k8s module tests passed!"
