{ config, pkgs, lib, ... }:

let
  # Helper function to create keybinding definitions
  mkKey = keymap: key: command:
    "(define-key ${keymap} (kbd \"${key}\") #'${command})";

  globalKey = mkKey "global-map";

  cfg = config.programs.emacs.init;
in
{

  programs.emacs.init.usePackage = {
    all-the-icons = { extraPackages = [ pkgs.emacs-all-the-icons-fonts ]; };
  };

  # Enable the Emacs module for Home Manager
  programs.emacs = {
    enable = true;

    # List of Emacs packages to install
    # These correspond to the packages previously managed by package.el and use-package
    extraPackages = epkgs: with epkgs; [
    ]; 

    # Emacs configuration translated from init.el
    /*
    extraConfig = ''
      ;; Basic UI Customizations
      (tool-bar-mode -1)      ; Disable toolbar
      (menu-bar-mode -1)      ; Disable menubar
      (scroll-bar-mode -1)    ; Disable scrollbars

      (savehist-mode +1)
      (recentf-mode +1)
      (save-place-mode +1)

      (setq inhibit-startup-message t) ; Disable startup message
      (setq initial-scratch-message nil) ; Clear scratch buffer message
      (global-display-line-numbers-mode 1) ; Enable line numbers globally

      ;; Indentation settings
      (setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
      (setq-default tab-width 4)         ; Set tab width to 4 spaces

      ;; Revert buffers automatically 
      (global-auto-revert-mode t)

      ;; highlight the current line
      (global-hl-line-mode +1)

      ;; show whitespace 
      (global-whitespace-mode +1)
      (setq whitespace-line-column 120) ;; limit line length
      (setq whitespace-style '(face tabs empty trailing lines-tail))
      ;; Backup and auto-save configuration
      (setq backup-directory-alist '(("." . "~/.emacs.d/backups"))) ; Store backups in ~/.emacs.d/backups
      (setq create-lockfiles nil)       ; Avoid creating lockfiles
      (setq auto-save-default nil)      ; Disable auto-saving
      ;; Ensure the backup directory exists
      (make-directory "~/.emacs.d/backups" t)

      ;; --- Package Configurations ---

      ;; undo-fu
      (undo-fu-session-global-mode)

      ;; which-key: Show keybindings
      (require 'which-key)
      (which-key-mode)

      ;; evil: Vim emulation
      (setq evil-want-keybinding nil) ; Do not overwrite Emacs keybindings by default (evil-collection handles many)
      (setq evil-want-integration t) ; Enable integration with other packages
      (require 'evil)
      (evil-mode 1) ; Enable Evil mode globally

      ;; evil-collection: Integrations for Evil
      ;; Needs to run after evil is loaded
      (with-eval-after-load 'evil
        (require 'evil-collection)
        (evil-collection-init))

      (require 'evil-multiedit)
      

      ;; set the theme 
      (load-theme 'catppuccin :no-confirm)

      ;; doom-modeline: Enable the modeline
      ;; Requires all-the-icons to be available
      (require 'doom-modeline)
      (doom-modeline-mode 1)

      ;; projectile: Project management
      (require 'projectile)
      (projectile-mode +1) ; Enable projectile mode globally
      ;; Keybinding for projectile commands (usually bound by default, but explicit here)
      (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

      ;; counsel-projectile: Projectile integration for Counsel
      (require 'counsel-projectile)
      (counsel-projectile-mode)

      ;; ivy, counsel, swiper: Completion framework
      (require 'ivy)
      (require 'counsel)
      (ivy-mode 1) ; Enable Ivy mode globally
      (setq ivy-use-virtual-buffers t) ; Include recent files/buffers in switch-buffer
      (setq enable-recursive-minibuffers t) ; Allow invoking commands needing minibuffer from within minibuffer

      ;; ivy-rich: Enhanced display for Ivy
      (require 'ivy-rich)
      (ivy-rich-mode 1)

      ;; helpful: Better help system
      (require 'helpful)
      ;; Note: Keybindings are set below in the dedicated keybinding section

      ;; company: Autocompletion
      (require 'company)
      (add-hook 'after-init-hook 'global-company-mode) ; Enable company mode globally after init

      ;; flycheck: Syntax checking
      (require 'flycheck)
      (add-hook 'after-init-hook 'global-flycheck-mode) ; Enable flycheck mode globally after init

      ;; --- Global Keybindings ---
      ;; (Using the helper function defined in the Nix 'let' block for clarity)
      ;; Note: Some bindings might be provided by packages like evil-collection automatically.
      ;; These bindings explicitly reflect the init.el setup.

      ;; Ivy/Counsel/Swiper Bindings
      ${globalKey "C-s" "swiper"}
      ${globalKey "C-x b" "ivy-switch-buffer"}
      ${globalKey "C-c v" "ivy-push-view"}
      ${globalKey "M-x" "counsel-M-x"}
      ${globalKey "M-y" "counsel-yank-pop"}

      ;; Counsel Bindings for Help/Info/Lookup (Consider using Helpful bindings below instead)
      ; ${globalKey "<f1> f" "counsel-describe-function"}
      ; ${globalKey "<f1> v" "counsel-describe-variable"}
      ${globalKey "<f1> l" "counsel-find-library"}
      ${globalKey "<f2> i" "counsel-info-lookup-symbol"}
      ${globalKey "<f2> u" "counsel-unicode-char"}

      ;; Counsel Bindings for Tools (Require external tools like git, ag, locate)
      ${globalKey "C-c g" "counsel-git"}
      ${globalKey "C-c j" "counsel-git-grep"}
      ${globalKey "C-c k" "counsel-ag"}        ; Requires 'ag' (the_silver_searcher)
      ${globalKey "C-x l" "counsel-locate"}    ; Requires 'locate' (mlocate/plocate)
      ; ${globalKey "C-S-o" "counsel-rhythmbox"} ; Requires rhythmbox integration

      ;; Minibuffer history binding for Ivy
      (define-key ivy-minibuffer-map (kbd "C-r") 'counsel-minibuffer-history)

      ;; Helpful Bindings (Recommended over counsel-describe-*)
      ${globalKey "C-h f" "helpful-callable"}  ; Help for functions/macros
      ${globalKey "C-h v" "helpful-variable"}  ; Help for variables
      ${globalKey "C-h k" "helpful-key"}       ; Help for keybindings
      ${globalKey "C-c C-d" "helpful-at-point"} ; Help for symbol at point

      ;; Final message indicating successful load (optional)
      (message "Nix-managed Emacs configuration loaded.")
    ''; # End of extraConfig
    */
  };
  # --- System Dependencies ---
  # Packages needed by Emacs packages but are not Emacs packages themselves
  home.packages = with pkgs; [
    # For counsel-ag / ripgrep integration
    silver-searcher # ag
    ripgrep             # rg (often preferred over ag)

    # For counsel-locate
    # Choose one: mlocate or plocate (plocate is often faster if available)
    # mlocate
    # plocate

    # Fonts for all-the-icons
    # Install a Nerd Font or the specific all-the-icons fonts package
    # (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; }) # Example: Install FiraCode and JetBrainsMono Nerd Fonts
    # Alternatively, if your nixpkgs has it:
    # all-the-icons-fonts
  ];

  # Ensure fontconfig is enabled if using font packages like nerdfonts
  fonts.fontconfig.enable = lib.mkDefault true;
}
