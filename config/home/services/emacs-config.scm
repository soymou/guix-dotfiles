(define-module (config home services emacs-config) ; Parentheses around module name are standard
  #:use-module (gnu home services)
  #:use-module (gnu home services emacs)
  #:use-module (gnu services)           ; Needed for the 'service' form
  #:use-module (guix gexp)              ; (guix gexp), not (gnu gexp)
  #:use-module (gnu packages emacs)     ; Needed for 'emacs' package
  #:use-module (gnu packages emacs-xyz) ; Needed for 'emacs-evil'
  #:export (emacs-config-services))

(define emacs-config-services
  (list
   ;; Service 1: Place your file as 'manual-init.el' to avoid conflict
   (service home-xdg-configuration-files-service-type
            `(("emacs/custom-init.el" ,(local-file "./../files/init.el"))))

   ;; Service 2: The Guix Emacs Service
   (service home-emacs-service-type
            (home-emacs-configuration
             (package emacs)
             (elisp-packages (list emacs-evil))
             (init-el
              ;; Load the separate file we defined above
              `((load (expand-file-name "custom-init.el" user-emacs-directory))))))))
