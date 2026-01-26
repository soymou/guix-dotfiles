;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(define-module (config systems desktop)
  #:use-module (config systems base-system)
  #:use-module (gnu)
  #:use-module (gnu services pm)
  #:use-module (nonguix transformations)
  #:use-module (nongnu packages nvidia))

(use-service-modules cups desktop networking ssh xorg)

(define desktop-os
  (operating-system
    (inherit base-system)
    (keyboard-layout (keyboard-layout "latam"))
    (host-name "mou")

    ;; The list of user accounts ('root' is implicit).
    (users (cons* (user-account
                  (name "mou")
                  (comment "mou")
                  (group "users")
                  (home-directory "/home/mou")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "input")))
                %base-user-accounts))


    (bootloader (bootloader-configuration
			(bootloader grub-efi-bootloader)
			(targets (list "/boot/efi"))
			(keyboard-layout keyboard-layout)))
    (swap-devices (list (swap-space
				(target (uuid
					 "c62129a1-9115-481d-985d-13288b8605cd")))))

    (file-systems (cons* (file-system
				 (mount-point "/boot/efi")
				 (device (uuid "1170-AEF0"
					       'fat32))
				 (type "vfat"))
			       (file-system
				 (mount-point "/")
				 (device (uuid
					  "cb858795-596b-4aaf-b771-00de98ca0829"
					  'ext4))
				 (type "ext4")) %base-file-systems))))

((nonguix-transformation-nvidia #:open-source-kernel-module? #t) desktop-os)



