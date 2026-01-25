(define-module (config systems base-system)
  #:use-module (gnu)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages wm)
  #:use-module (guix)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (soymou packages sddm-astronaut-theme)
  #:export (base-system))

(use-service-modules cups desktop networking sddm ssh xorg)

(define base-system
  (operating-system
    (kernel linux)
    (kernel-arguments '("nvidia_drm.modeset=1"))
    (initrd microcode-initrd)
    (firmware (list linux-firmware))
    (host-name "base-system")
    (timezone "America/Mexico_City")
    (locale "en_US.UTF-8")
    (keyboard-layout (keyboard-layout "latam"))

    ;; These are required for the record to be valid, 
    ;; even though laptop.scm will overwrite them.
    (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
    (swap-devices (list (swap-space
                        (target (uuid
                                 "b4fa5d59-f2d4-4a73-91d8-07c579add08d")))))

    (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "15B5-56D2"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device (uuid
                                  "3cbf18aa-9a24-4cc3-a7f7-2de07475bee9"
                                  'ext4))
                         (type "ext4")) %base-file-systems))

    (packages (append (list (specification->package "gnome")
                            ;; Window managers
                            niri
                            ;; SDDM theme
                            sddm-astronaut-theme
                            ;; Qt6 modules for themes
                            (specification->package "qtmultimedia")
                            (specification->package "gst-plugins-base")
                            (specification->package "gst-plugins-good")
                            ;; X11 libraries often needed by Rust/Winit
                            (specification->package "libxcursor")
                            (specification->package "libxrandr")
                            (specification->package "libxi")
                            (specification->package "libxfixes")
                            ;; Fonts
                            font-fira-code
                            font-fira-mono
                            font-jetbrains-mono
                            font-hack
                            font-iosevka
                            font-iosevka-term
                            font-liberation
                            font-dejavu
                            font-google-noto
                            font-google-noto-emoji)
		      %base-packages))

    (services
      (append
        (list (service openssh-service-type)
              (service tor-service-type)
              (service cups-service-type)
	      (service bluetooth-service-type
		       (bluetooth-configuration
			 (auto-enable? #t)))
              ;; Use SDDM instead of GDM (GDM disables Wayland on hybrid NVIDIA laptops)
              ;; Greeter runs on X11 for stability, but Wayland sessions (Niri) are selectable
              (service sddm-service-type
                       (sddm-configuration
                        (display-server "x11")
                        (numlock "none")
                        (theme "astronaut")
                        (themes-directory "/run/current-system/profile/share/sddm/themes"))))

        (modify-services %desktop-services
          ;; Remove GDM (replaced by SDDM above)
          (delete gdm-service-type)
          (guix-service-type config => (guix-configuration
            (inherit config)
            (substitute-urls
             (append (list "https://substitutes.nonguix.org")
                     %default-substitute-urls))
            (authorized-keys
             (append (list (local-file "./signing-key.pub"))
                     %default-authorized-guix-keys)))))))
    ))
