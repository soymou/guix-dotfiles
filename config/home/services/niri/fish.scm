(define-module (config home services niri fish)
  #:use-module (guix gexp)
  #:export (fish-config-patch))

(define fish-config (local-file "configs/config.fish"))

(define (fish-config-patch)
  #~(let ((d (string-append #$output "/dots/.config/fish")))
      (mkdir-p d)
      (copy-file #$fish-config (string-append d "/config.fish"))))
