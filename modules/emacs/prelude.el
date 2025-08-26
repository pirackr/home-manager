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
;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

;; delete the selection with a keypress
(delete-selection-mode t)

;; the blinking cursor is nothing, but an annoyance
(blink-cursor-mode -1)

;; Turn off UI elements
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))      ; Disable toolbar
(menu-bar-mode -1)         ; Disable menubar
(scroll-bar-mode -1)       ; Disable scrollbars

;; mode line settings
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

;; highlight the current line
(global-hl-line-mode +1)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)
(global-whitespace-mode +1)

(savehist-mode +1)
(recentf-mode +1)
(save-place-mode +1)

;; disable startup screen and messages
(setq inhibit-startup-message t) ; Disable startup message
(setq inhibit-startup-screen t)  ; Disable startup screen
(setq initial-scratch-message nil) ; Clear scratch buffer message
(global-display-line-numbers-mode 1) ; Enable line numbers globally

;; Indentation settings
(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
(setq-default tab-width 4)         ; Set tab width to 4 spaces

(defconst doom-system
  (pcase system-type
    ('darwin                           '(macos bsd))
    ((or 'cygwin 'windows-nt 'ms-dos)  '(windows))
    ((or 'gnu 'gnu/linux)              '(linux))
    ((or 'gnu/kfreebsd 'berkeley-unix) '(linux bsd))
    ('android                          '(android)))
  "A list of symbols denoting available features in the active Doom profile.")

;; Convenience aliases for internal use only (may be removed later).
(defconst doom--system-windows-p (eq 'windows (car doom-system)))
(defconst doom--system-macos-p   (eq 'macos   (car doom-system)))
(defconst doom--system-linux-p   (eq 'linux   (car doom-system)))

;; set modifier for macosx/windows
(cond
 (doom--system-macos-p
  ;; mac-* variables are used by the special emacs-mac build of Emacs by
  ;; Yamamoto Mitsuharu, while other builds use ns-*.
  (setq mac-command-modifier      'super
        ns-command-modifier       'super
        mac-option-modifier       'meta
        ns-option-modifier        'meta
        ;; Free up the right option for character composition
        mac-right-option-modifier 'none
        ns-right-option-modifier  'none))
 (doom--system-windows-p
  (setq w32-lwindow-modifier 'super

        w32-rwindow-modifier 'super)))

;; User settings
(setq user-full-name "Pirackr"
      user-mail-address "pirackr@gmail.com")

;; Always load newest byte code
(setq load-prefer-newer t)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

(defconst pirackr-savefile-dir (expand-file-name "savefile" user-emacs-directory))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p pirackr-savefile-dir)
  (make-directory pirackr-savefile-dir))

;; disable the annoying bell ring
(setq ring-bell-function 'ignore)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; Newline at end of file
(setq require-final-newline t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;; Encoding settings
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; Whitespace settings
(setq whitespace-line-column 120) ;; limit line length
(setq whitespace-style '(face tabs empty trailing lines-tail))

;; Key bindings
;; replace buffer-menu with ibuffer
(global-set-key (kbd "C-x C-b") #'ibuffer)