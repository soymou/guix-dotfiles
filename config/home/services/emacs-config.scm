(define-module (config home services emacs-config)
  #:use-module (gnu home services)
  #:use-module (gnu packages emacs)     ; For the 'emacs' package variable
  #:use-module (gnu packages emacs-xyz) ; For extensions like 'emacs-evil'
  #:use-module (guix gexp)
  #:export (emacs-config-service))

(define emacs-config-service
  (list
   ;; 1. Install Emacs and plugins
   ;; We use 'simple-service' to add packages to your profile automatically.
   (simple-service 'emacs-packages
                   home-profile-service-type
                   (list emacs
                         emacs-evil))

   ;; 2. Configure init.el
   ;; This links your local file to ~/.config/emacs/init.el
   (simple-service 'emacs-config
                   home-xdg-configuration-files-service-type
                   `(("emacs/init.el" ,(local-file "../files/init.el"))))
   ))
