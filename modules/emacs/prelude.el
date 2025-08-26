;; Straight.el package manager setup
;; Install straight.el if not already installed
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Configure use-package to use straight.el
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

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
(global-hl-line-mode 1)
