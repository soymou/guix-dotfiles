(define-module (config home services niri foot)
  #:use-module (guix gexp)
  #:export (foot-config-patch))

(define foot-ini (local-file "configs/foot.ini"))

(define (foot-config-patch)
  #~(let ((d (string-append #$output "/dots/.config/foot")))
      (mkdir-p d)
      (copy-file #$foot-ini (string-append d "/foot.ini"))))
