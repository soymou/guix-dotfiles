;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(define-module (config systems laptop)
  #:use-module (config systems base-system)
  #:use-module (gnu)
  #:use-module (nonguix transformations)
  #:use-module (nongnu packages nvidia))

(use-service-modules cups desktop networking ssh xorg)

(define laptop-os
  (operating-system
    (inherit base-system)
    (keyboard-layout (keyboard-layout "es"))
    (host-name "mou-laptop")

    ;; The list of user accounts ('root' is implicit).
    (users (cons* (user-account
                  (name "mou")
                  (comment "mou")
                  (group "users")
                  (home-directory "/home/mou")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))


    (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
    (swap-devices (list (swap-space
                        (target (uuid
                                 "b4fa5d59-f2d4-4a73-91d8-07c579add08d")))))

    ;; The list of file systems that get "mounted".  The unique
    ;; file system identifiers there ("UUIDs") can be obtained
    ;; by running 'blkid' in a terminal.
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
                         (type "ext4")) %base-file-systems)))
  )

((nonguix-transformation-nvidia #:configure-xorg? #t) laptop-os)



