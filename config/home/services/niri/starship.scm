(define-module (config home services niri starship)
  #:use-module (guix gexp)
  #:export (starship-config-patch))

(define starship-toml (local-file "configs/starship.toml"))

(define (starship-config-patch)
  #~(let ((d (string-append #$output "/defaults/matugen/templates/starship")))
      (mkdir-p d)
      (copy-file #$starship-toml (string-append d "/starship.toml"))))
