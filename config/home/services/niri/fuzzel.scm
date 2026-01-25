(define-module (config home services niri fuzzel)
  #:use-module (guix gexp)
  #:use-module (ice-9 textual-ports)
  #:export (fuzzel-config-patch))

(define fuzzel-ini (local-file "configs/fuzzel.ini"))

(define (fuzzel-config-patch)
  #~(let ((f (string-append #$output "/dots/.config/fuzzel/fuzzel.ini")))
      (mkdir-p (dirname f))
      (copy-file #$fuzzel-ini f)
      (make-file-writable f)
      (let ((c (call-with-input-file f get-string-all)))
        (call-with-output-file f
          (lambda (p) (display c p) (display "\ninclude=~/.cache/matugen/fuzzel.ini\n" p))))))
