{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Nix language support
      nix-mode = {
        enable = true;
        package = epkgs: epkgs.nix-mode;
        defer = true;
        mode = [ "\\.nix\\'" ];
        hook = [
          "(nix-mode . eglot-ensure)"
        ];
        config = ''
          ;; Configure nix-mode settings
          (setq nix-nixfmt-bin "nixpkgs-fmt")
        '';
      };
    };
  };
}