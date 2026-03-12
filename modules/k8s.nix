{ config, pkgs, lib, ... }:

{
  options.modules.k8s = {
    enable = lib.mkEnableOption "Kubernetes tools configuration";
  };

  config = lib.mkIf config.modules.k8s.enable {
    home.packages = [
      pkgs.kind
      pkgs.kubectl
      pkgs.kubelogin
    ];
  };
}
