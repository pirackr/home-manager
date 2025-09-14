{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.emacs.enable {
    programs.emacs.init.usePackage = {
      # Infrastructure as Code - HCL
      hcl-mode = {
        enable = true;
        package = epkgs: epkgs.hcl-mode;
        defer = true;
        mode = [ "\\.hcl\\'" ];
      };

      # Terraform support
      terraform-mode = {
        enable = true;
        package = epkgs: epkgs.terraform-mode;
        defer = true;
        mode = [ "\\.tf\\'" "\\.tfvars\\'" ];
        hook = [
          "(terraform-mode . eglot-ensure)"
          "(terraform-mode . outline-minor-mode)"
        ];
        config = ''
          ;; Terraform-specific configuration
          (setq terraform-indent-level 2)
        '';
      };
    };
  };
}