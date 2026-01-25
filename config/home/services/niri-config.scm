(define-module (config home services niri-config)
  #:use-module (gnu home services)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services sound)
  #:use-module (gnu packages base)
  #:use-module (gnu packages polkit)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git)
  #:use-module (ice-9 match)
  #:use-module (config home services niri fonts)
  #:use-module (config home services niri packages)
  #:use-module (config home services niri core)
  #:use-module (config home services niri theme)
  #:use-module (config home services niri foot)
  #:use-module (config home services niri fish)
  #:use-module (config home services niri starship)
  #:use-module (config home services niri quickshell)
  #:use-module (config home services niri gtk)
  #:use-module (config home services niri matugen)
  #:use-module (config home services niri fuzzel)
  #:use-module (config home services niri niri)
  #:export (niri-config-service
            niri-config-from-git
            %inir-fontconfig))

(define inir-source (local-file "/home/mou/Desktop/Personal/dotfiles/iNiR" #:recursive? #t))

(define inir-checkout
  (computed-file "patched-inir"
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils) (ice-9 rdelim) (ice-9 textual-ports))
          (copy-recursively #$inir-source #$output)
          
          ;; Global patches
          #$(core-config-patch)
          #$(theme-config-patch)
          
          ;; Per-program patches/configs
          #$(quickshell-config-patch)
          #$(niri-config-patch)
          #$(foot-config-patch)
          #$(matugen-config-patch)
          #$(fuzzel-config-patch)
          #$(gtk-config-patch)
          #$(starship-config-patch)
          #$(fish-config-patch)))))

(define %inir-fontconfig '((match (@ (target "font")) (edit (@ (name "rgba") (mode "assign")) (const "none")))))

(define %inir-file-mappings
  '(("niri/config.kdl" . "dots/.config/niri/config.kdl") ("fuzzel/fuzzel.ini" . "dots/.config/fuzzel/fuzzel.ini")
    ("foot/foot.ini" . "dots/.config/foot/foot.ini") ("gtk-3.0/settings.ini" . "dots/.config/gtk-3.0/settings.ini")
    ("gtk-4.0/settings.ini" . "dots/.config/gtk-4.0/settings.ini") ("gtk-3.0/gtk.css" . "dots/.config/gtk-3.0/gtk.css")
    ("gtk-4.0/gtk.css" . "dots/.config/gtk-4.0/gtk.css") ("matugen/config.toml" . "dots/.config/matugen/config.toml")
    ("matugen/templates" . "defaults/matugen/templates")
    ("fish/config.fish" . "dots/.config/fish/config.fish")))

(define (make-config-files checkout mappings) (map (match-lambda ((target . source) `(,target ,(file-append checkout "/" source)))) mappings))
(define (make-quickshell-config checkout) `(("quickshell/ii" ,checkout)))

(define niri-config-service
  (list (simple-service 'niri-packages home-profile-service-type %niri-packages)
        (simple-service 'niri-config-files home-xdg-configuration-files-service-type (make-config-files inir-checkout %inir-file-mappings))
        (simple-service 'quickshell-ii-config home-xdg-configuration-files-service-type (make-quickshell-config inir-checkout))
        (simple-service 'niri-fontconfig home-fontconfig-service-type %inir-fontconfig)))

(define* (niri-config-from-git #:key repo-url repo-commit (file-mappings %inir-file-mappings) (fontconfig %inir-fontconfig))
  (let ((checkout (git-checkout (url repo-url) (commit repo-commit))))
    (append (list (simple-service 'niri-packages home-profile-service-type %niri-packages)
                  (simple-service 'niri-config-files home-xdg-configuration-files-service-type (make-config-files checkout file-mappings))
                  (simple-service 'quickshell-ii-config home-xdg-configuration-files-service-type (make-quickshell-config checkout)))
            (if fontconfig (list (simple-service 'niri-fontconfig home-fontconfig-service-type fontconfig)) '()))))
