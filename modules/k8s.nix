{ config, pkgs, lib, ... }:

{
  options.modules.k8s = {
    enable = lib.mkEnableOption "Kubernetes tools configuration";
  };

  config = lib.mkIf config.modules.k8s.enable {
    home.packages = [
      pkgs.kind
      pkgs.kubectl
      pkgs.kubelogin-oidc
      
      # Kubelogin wrapper script
      (pkgs.writeShellApplication {
        name = "kubelogin";
        text = ''
          # Create a modified PATH that excludes the current script's directory
          CLEANED_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/nix/store' | paste -sd ':' -)
          
          # Find the real kubelogin binary in the cleaned PATH (should be homebrew version)
          REAL_KUBELOGIN=$(PATH="$CLEANED_PATH" command -v kubelogin)
          
          if [[ -z "$REAL_KUBELOGIN" ]]; then
            echo "Error: real kubelogin binary not found in PATH."
            exit 1
          fi
          
          # Default base cache directory
          BASE_CACHE_DIR="$HOME/.kube/cache/kubelogin"
          
          # Capture the original arguments
          ARGS=("$@")
          
          # Extract --environment if present
          ENVIRONMENT=""
          for ((i=0; i < ''${#ARGS[@]}; i++)); do
            if [[ "''${ARGS[$i]}" == "--environment" && $((i+1)) -lt ''${#ARGS[@]} ]]; then
              ENVIRONMENT="''${ARGS[$((i+1))]}"
              break
            fi
          done
          
          # Append custom cache dir if environment was set
          if [[ -n "$ENVIRONMENT" ]]; then
            CACHE_DIR="$BASE_CACHE_DIR/$ENVIRONMENT"
            mkdir -p "$CACHE_DIR"
            exec "$REAL_KUBELOGIN" "''${ARGS[@]}" --token-cache-dir="$CACHE_DIR"
          else
            exec "$REAL_KUBELOGIN" "''${ARGS[@]}"
          fi
        '';
      })
    ];
  };
}
