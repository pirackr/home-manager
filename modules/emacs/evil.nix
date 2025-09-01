{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.modules.emacs.enable && config.modules.emacs.evil) {
    programs.emacs.init.usePackage = {
      evil = {
        enable = true;
        package = epkgs: epkgs.evil;
        hook = [ "(org-mode . (lambda () evil-org-mode))" ];
        init = ''
          (setq evil-undo-system 'undo-fu)
          (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
          (setq evil-want-keybinding nil)
        '';
        config = ''
          (evil-mode 1)
        '';
      };

      evil-leader = {
        enable = true;
        package = epkgs: epkgs.evil-leader;
        after = [ "evil" ];
        config = ''
          (global-evil-leader-mode t)
          (evil-leader/set-leader "<SPC>")
          (evil-leader/set-key
            "a" 'org-agenda
            "p f" 'projectile-find-file
            "p p" 'projectile-switch-project
            "p s" 'consult-ripgrep
            "d x w" 'delete-trailing-whitespace)
        '';
      };

      evil-surround = {
        enable = true;
        package = epkgs: epkgs.evil-surround;
        after = [ "evil" ];
        config = ''
          (global-evil-surround-mode 1)
        '';
      };

      evil-collection = {
        enable = true;
        package = epkgs: epkgs.evil-collection;
        after = [ "evil" ];
        config = ''
          (when (require 'evil-collection nil t)
            (evil-collection-init))
        '';
      };

      treemacs-evil = {
        enable = true;
        package = epkgs: epkgs.treemacs-evil;
        after = [ "treemacs" "evil" ];
      };

      evil-org = {
        enable = true;
        package = epkgs: epkgs.evil-org;
        after = [ "org" "evil" ];
        hook = [ "(org-mode . evil-org-mode)" ];
        config = ''
          (require 'evil-org-agenda)
          (evil-org-agenda-set-keys)
        '';
      };
    };
  };
}
