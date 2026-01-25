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
  #:use-module (soymou services niri-config-service)
  #:use-module (soymou services niri-startup-service)
  #:use-module (soymou services shell-config-service)
  #:use-module (soymou services gtk-theme-service)
  #:use-module (soymou services flatpak-service))

(home-environment
  (packages (list htop git flatpak node python zathura zathura-pdf-poppler steam-nvidia))
  (services
    (append
     (list (service home-bash-service-type
                    (home-bash-configuration
                     (environment-variables
                      '(;; NPM global bin path
                        ("PATH" . "$HOME/.npm-global/bin:$PATH")

                        ;; Qt/QML paths for quickshell (use $HOME instead of hardcoded path)
                        ("QML_IMPORT_PATH" . "$HOME/.guix-home/profile/lib/qt6/qml")
                        ("QML2_IMPORT_PATH" . "$HOME/.guix-home/profile/lib/qt6/qml")

                        ;; Python site-packages for GUIX profile
                        ("PYTHONPATH" . "$HOME/.guix-home/profile/lib/python3.11/site-packages")

                        ;; XDG_DATA_DIRS for icons and applications (GUIX profile paths)
                        ;; This fixes missing icons in quickshell dock and app launcher
                        ("XDG_DATA_DIRS" . "$HOME/.guix-home/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share:$XDG_DATA_DIRS"))))))

     ;; Emacs configuration
     emacs-config-service

     ;; iNiR core (GUIX compatibility patches, packages, fonts)
     ;; Note: This does NOT install niri config.kdl - use niri-startup-service for that
     (niri-config-from-git
       #:repo-url "https://github.com/soymou/iNiR"
       #:repo-commit "main")

     ;; Personal niri startup (pipewire, wireplumber, ii-setup, quickshell)
     niri-startup-service

     ;; Personal shell configs (foot, fish, starship)
     shell-config-service

     ;; Personal GTK theming (Material You via matugen)
     gtk-theme-service

     ;; Flatpak applications
     (flatpak-service
      '("app.zen_browser.zen"
        "com.spotify.Client"
        "com.discordapp.Discord"
        ;; Audio effects for iNiR quick settings
        "com.github.wwmm.easyeffects"
        ;; Music recognition (Shazam-like) for iNiR
        "re.fossplant.songrec")))))
