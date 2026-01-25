;;; init.el --- Full-featured Emacs config -*- lexical-binding: t; -*-

;; Use-package is installed by Guix
(require 'use-package)
(setq use-package-always-ensure nil)

;;; ============================================================================
;;; Basic Settings
;;; ============================================================================

;; Disable UI clutter
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)

;; Better defaults
(setq-default
 indent-tabs-mode nil
 tab-width 4
 fill-column 80
 sentence-end-double-space nil
 create-lockfiles nil
 make-backup-files nil
 auto-save-default nil)

;; UTF-8 everywhere
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)

;; Line numbers
(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Scroll settings
(setq scroll-margin 8
      scroll-conservatively 101
      scroll-preserve-screen-position t)

;; Remember cursor position
(save-place-mode 1)

;; Auto-revert files when changed on disk
(global-auto-revert-mode 1)

;; y/n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

;; Show matching parens
(show-paren-mode 1)

;;; ============================================================================
;;; Evil Settings (must be before evil loads)
;;; ============================================================================

(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-i-jump nil)
(setq evil-undo-system 'undo-tree)

;;; ============================================================================
;;; Appearance
;;; ============================================================================

(use-package doom-themes
  :demand t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package all-the-icons
  :demand t)

(use-package doom-modeline
  :demand t
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 35)
  (doom-modeline-bar-width 5)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-lsp t)
  (doom-modeline-github nil)
  (doom-modeline-minor-modes nil)
  (doom-modeline-persp-name nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-indent-info nil))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package dashboard
  :demand t
  :custom
  (dashboard-banner-logo-title "Welcome to Emacs")
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-items '((recents  . 5)
                     (projects . 5)
                     (bookmarks . 5)))
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  :config
  (dashboard-setup-startup-hook))

;;; ============================================================================
;;; Evil Mode
;;; ============================================================================

(defun rune/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :demand t
  :hook (evil-mode . rune/evil-hook)
  :config
  (evil-mode 1)
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :demand t
  :config
  (evil-collection-init))

(use-package evil-nerd-commenter
  :after evil
  :demand t)

(use-package undo-tree
  :demand t
  :config
  (global-undo-tree-mode)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))

;;; ============================================================================
;;; Keybindings
;;; ============================================================================

(use-package general
  :after evil
  :demand t
  :config
  (general-evil-setup t)

  (general-create-definer leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer local-leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix ","
    :global-prefix "C-,")

  ;; Top-level
  (leader-keys
    "SPC" '(counsel-M-x :which-key "M-x")
    "." '(find-file :which-key "find file")
    "," '(switch-to-buffer :which-key "switch buffer")
    ":" '(eval-expression :which-key "eval")
    "x" '(scratch-buffer :which-key "scratch")
    "q" '(save-buffers-kill-terminal :which-key "quit"))

  ;; Files
  (leader-keys
    "f" '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "fr" '(counsel-recentf :which-key "recent files")
    "fs" '(save-buffer :which-key "save")
    "fS" '(write-file :which-key "save as")
    "fR" '(rename-file :which-key "rename"))

  ;; Buffers
  (leader-keys
    "b" '(:ignore t :which-key "buffers")
    "bb" '(switch-to-buffer :which-key "switch")
    "bd" '(kill-current-buffer :which-key "kill")
    "bD" '(kill-buffer :which-key "kill other")
    "bn" '(next-buffer :which-key "next")
    "bp" '(previous-buffer :which-key "previous")
    "br" '(revert-buffer :which-key "revert")
    "bi" '(ibuffer :which-key "ibuffer"))

  ;; Windows
  (leader-keys
    "w" '(:ignore t :which-key "windows")
    "ww" '(other-window :which-key "other")
    "wd" '(delete-window :which-key "delete")
    "wD" '(delete-other-windows :which-key "delete others")
    "ws" '(split-window-below :which-key "split below")
    "wv" '(split-window-right :which-key "split right")
    "wh" '(windmove-left :which-key "left")
    "wj" '(windmove-down :which-key "down")
    "wk" '(windmove-up :which-key "up")
    "wl" '(windmove-right :which-key "right")
    "w=" '(balance-windows :which-key "balance"))

  ;; Window navigation with numbers
  (leader-keys
    "1" '(winum-select-window-1 :which-key "window 1")
    "2" '(winum-select-window-2 :which-key "window 2")
    "3" '(winum-select-window-3 :which-key "window 3")
    "4" '(winum-select-window-4 :which-key "window 4")
    "5" '(winum-select-window-5 :which-key "window 5"))

  ;; Project
  (leader-keys
    "p" '(:ignore t :which-key "project")
    "pp" '(projectile-switch-project :which-key "switch")
    "pf" '(projectile-find-file :which-key "find file")
    "pg" '(projectile-grep :which-key "grep")
    "pb" '(projectile-switch-to-buffer :which-key "buffers")
    "pk" '(projectile-kill-buffers :which-key "kill buffers")
    "pr" '(projectile-recentf :which-key "recent")
    "ps" '(projectile-save-project-buffers :which-key "save all"))

  ;; Search
  (leader-keys
    "s" '(:ignore t :which-key "search")
    "ss" '(swiper :which-key "swiper")
    "sp" '(counsel-projectile-rg :which-key "project rg")
    "sP" '(counsel-rg :which-key "rg")
    "si" '(counsel-imenu :which-key "imenu")
    "sr" '(counsel-mark-ring :which-key "mark ring"))

  ;; Code
  (leader-keys
    "c" '(:ignore t :which-key "code")
    "cc" '(evilnc-comment-or-uncomment-lines :which-key "comment")
    "cp" '(evilnc-comment-or-uncomment-paragraphs :which-key "comment para")
    "cy" '(evilnc-copy-and-comment-lines :which-key "copy & comment")
    "ca" '(lsp-execute-code-action :which-key "code action")
    "cd" '(lsp-find-definition :which-key "definition")
    "cr" '(lsp-find-references :which-key "references")
    "cR" '(lsp-rename :which-key "rename")
    "cf" '(lsp-format-buffer :which-key "format")
    "ce" '(flycheck-list-errors :which-key "errors"))

  ;; Git
  (leader-keys
    "g" '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "status")
    "gb" '(magit-blame :which-key "blame")
    "gl" '(magit-log-current :which-key "log")
    "gd" '(magit-diff-unstaged :which-key "diff")
    "gf" '(magit-fetch :which-key "fetch")
    "gF" '(magit-pull :which-key "pull")
    "gp" '(magit-push :which-key "push"))

  ;; Toggle
  (leader-keys
    "t" '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "theme")
    "tf" '(treemacs :which-key "treemacs")
    "tn" '(display-line-numbers-mode :which-key "line numbers")
    "tr" '(toggle-truncate-lines :which-key "truncate lines")
    "tw" '(whitespace-mode :which-key "whitespace"))

  ;; Help
  (leader-keys
    "h" '(:ignore t :which-key "help")
    "hf" '(helpful-callable :which-key "function")
    "hv" '(helpful-variable :which-key "variable")
    "hk" '(helpful-key :which-key "key")
    "hd" '(helpful-at-point :which-key "at point")
    "hm" '(describe-mode :which-key "mode"))

  ;; Open
  (leader-keys
    "o" '(:ignore t :which-key "open")
    "ot" '(vterm :which-key "terminal")
    "oe" '(eshell :which-key "eshell")
    "od" '(dired :which-key "dired")))

(use-package which-key
  :demand t
  :init (which-key-mode)
  :diminish which-key-mode
  :custom
  (which-key-idle-delay 0.3)
  (which-key-prefix-prefix "+")
  (which-key-sort-order 'which-key-key-order-alpha))

(use-package hydra
  :demand t)

(use-package winum
  :demand t
  :config
  (winum-mode))

;;; ============================================================================
;;; Completion & Search
;;; ============================================================================

(use-package ivy
  :demand t
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d) ")
  (ivy-wrap t)
  (ivy-height 15)
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :demand t
  :config
  (ivy-rich-mode 1))

(use-package counsel
  :after ivy
  :demand t
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (counsel-mode 1))

(use-package swiper
  :after ivy
  :demand t)

(use-package company
  :demand t
  :hook (after-init . global-company-mode)
  :bind (:map company-active-map
         ("C-j" . company-select-next)
         ("C-k" . company-select-previous)
         ("TAB" . company-complete-selection)
         ("<tab>" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1)
  (company-tooltip-align-annotations t)
  (company-selection-wrap-around t))

(use-package company-box
  :after company
  :hook (company-mode . company-box-mode))

;;; ============================================================================
;;; Project & File Management
;;; ============================================================================

(use-package projectile
  :demand t
  :diminish projectile-mode
  :custom
  (projectile-project-search-path '("~/projects/" "~/code/"))
  (projectile-completion-system 'ivy)
  (projectile-switch-project-action #'projectile-dired)
  :config
  (projectile-mode 1))

(use-package treemacs
  :demand t
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  (treemacs-show-hidden-files t)
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

;;; ============================================================================
;;; Git
;;; ============================================================================

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package git-gutter
  :demand t
  :hook (prog-mode . git-gutter-mode)
  :custom
  (git-gutter:update-interval 0.5))

;;; ============================================================================
;;; Programming
;;; ============================================================================

(use-package flycheck
  :demand t
  :hook (prog-mode . flycheck-mode)
  :custom
  (flycheck-emacs-lisp-load-path 'inherit))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((rust-mode . lsp-deferred)
         (go-mode . lsp-deferred)
         (typescript-mode . lsp-deferred)
         (python-mode . lsp-deferred))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-idle-delay 0.5)
  (lsp-enable-symbol-highlighting t)
  (lsp-enable-snippet t)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-modeline-diagnostics-enable t)
  (lsp-modeline-code-actions-enable t)
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-code-actions t))

(use-package lsp-ivy
  :after (lsp-mode ivy)
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :commands lsp-treemacs-errors-list)

(use-package yasnippet
  :demand t
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package smartparens
  :demand t
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config))

;;; ============================================================================
;;; Languages
;;; ============================================================================

(use-package rust-mode
  :mode "\\.rs\\'"
  :custom
  (rust-format-on-save t))

(use-package go-mode
  :mode "\\.go\\'"
  :hook (before-save . gofmt-before-save))

(use-package typescript-mode
  :mode "\\.ts\\'")

(use-package json-mode
  :mode "\\.json\\'")

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package markdown-mode
  :mode "\\.md\\'"
  :custom
  (markdown-command "pandoc"))

;;; ============================================================================
;;; Utilities
;;; ============================================================================

(use-package helpful
  :demand t
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

;;; ============================================================================
;;; Custom keybindings (non-leader)
;;; ============================================================================

;; ESC cancels all
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Window navigation with C-hjkl
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-l") 'windmove-right)

;; Resize windows with C-S-hjkl
(global-set-key (kbd "C-S-h") 'shrink-window-horizontally)
(global-set-key (kbd "C-S-l") 'enlarge-window-horizontally)
(global-set-key (kbd "C-S-k") 'shrink-window)
(global-set-key (kbd "C-S-j") 'enlarge-window)

(provide 'init)
;;; init.el ends here
