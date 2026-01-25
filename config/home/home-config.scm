(define-module (config home home-config)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages node)
  #:use-module (gnu packages python)
  #:use-module (gnu packages pdf)
  #:use-module (nongnu packages game-client)
  #:use-module (config home services emacs-config)
  #:use-module (config home services niri-config)
  #:use-module (config home services flatpak))

(home-environment
  (packages (list htop git flatpak node python zathura steam-nvidia))
  (services
    (append
     (list (service home-bash-service-type
                    (home-bash-configuration
                     (environment-variables
                      '(("PATH" . "$HOME/.npm-global/bin:$PATH")
                        ("QML_IMPORT_PATH" . "/home/mou/.guix-home/profile/lib/qt6/qml")
                        ("QML2_IMPORT_PATH" . "/home/mou/.guix-home/profile/lib/qt6/qml")
                        ("PYTHONPATH" . "/home/mou/.guix-home/profile/lib/python3.11/site-packages"))))))
     emacs-config-service
     ;; Niri config from local folder
     niri-config-service

     (simple-flatpak-service
      '("app.zen_browser.zen"
        "com.spotify.Client"
        "com.discordapp.Discord"
        "com.mitchellh.ghostty")))))
