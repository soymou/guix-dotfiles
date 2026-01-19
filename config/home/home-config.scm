(define-module (config home home-config)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages version-control)
  #:use-module (config home services emacs-config)
  #:use-module (config home services flatpak))

(home-environment
  (packages (list htop git flatpak))
  (services
    (append
     (list (service home-bash-service-type))
     emacs-config-service
     (simple-flatpak-service
      '("app.zen_browser.zen"
	"com.spotify.Client"
	"com.discordapp.Discord")))))
