(define-module (config home services niri quickshell)
  #:use-module (guix gexp)
  #:export (quickshell-config-patch))

(define ii-setup-sh (local-file "configs/ii-setup.sh"))

(define (quickshell-config-patch)
  #~(let ((f (string-append #$output "/scripts/ii-setup.sh")))
      (copy-file #$ii-setup-sh f)
      (chmod f #o755)))
