(define-module (config home services emacs-config)
  #:use-module (gnu home services)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (guix gexp)
  #:export (emacs-config-service))

(define emacs-config-service
  (list
   (simple-service 'emacs-packages
                   home-profile-service-type
                   (list emacs
                         emacs-use-package
                         ;; Appearance
                         emacs-doom-themes
                         emacs-doom-modeline
                         emacs-all-the-icons
                         emacs-rainbow-delimiters
                         emacs-dashboard
                         ;; Evil mode
                         emacs-evil
                         emacs-evil-collection
                         emacs-evil-nerd-commenter
                         ;; Keybindings
                         emacs-general
                         emacs-which-key
                         emacs-hydra
                         ;; Completion & search
                         emacs-ivy
                         emacs-counsel
                         emacs-ivy-rich
                         emacs-swiper
                         emacs-company
                         emacs-company-box
                         ;; Project & file management
                         emacs-projectile
                         emacs-treemacs
                         ;; Git
                         emacs-magit
                         emacs-git-gutter
                         ;; Programming
                         emacs-flycheck
                         emacs-lsp-mode
                         emacs-lsp-ui
                         emacs-lsp-ivy
                         emacs-lsp-treemacs
                         emacs-yasnippet
                         emacs-yasnippet-snippets
                         emacs-smartparens
                         ;; Languages
                         emacs-rust-mode
                         emacs-go-mode
                         emacs-typescript-mode
                         emacs-json-mode
                         emacs-yaml-mode
                         emacs-markdown-mode
                         ;; Utilities
                         emacs-helpful
                         emacs-undo-tree
                         emacs-winum))

   (simple-service 'emacs-config
                   home-xdg-configuration-files-service-type
                   `(("emacs/init.el" ,(local-file "../../../files/emacs/init.el"))))))
