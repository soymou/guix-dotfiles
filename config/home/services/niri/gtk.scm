(define-module (config home services niri gtk)
  #:use-module (guix gexp)
  #:export (gtk-config-patch))

(define gtk3-settings (local-file "configs/gtk3-settings.ini"))
(define gtk4-settings (local-file "configs/gtk4-settings.ini"))

(define (gtk-config-patch)
  #~(begin
      (let ((s3 (string-append #$output "/dots/.config/gtk-3.0/settings.ini"))
            (s4 (string-append #$output "/dots/.config/gtk-4.0/settings.ini")))
        (mkdir-p (dirname s3)) (copy-file #$gtk3-settings s3)
        (mkdir-p (dirname s4)) (copy-file #$gtk4-settings s4))
      (let ((g3 (string-append #$output "/dots/.config/gtk-3.0/gtk.css"))
            (g4 (string-append #$output "/dots/.config/gtk-4.0/gtk.css")))
        (mkdir-p (dirname g3))
        (mkdir-p (dirname g4))
        (call-with-output-file g3 (lambda (p) (display "@import url(\"file:///home/mou/.cache/matugen/gtk3.css\");\n@import url(\"file:///home/mou/.cache/matugen/gtk3_extra.css\");\n" p)))
        (call-with-output-file g4 (lambda (p) (display "@import url(\"file:///home/mou/.cache/matugen/gtk4.css\");\n@import url(\"file:///home/mou/.cache/matugen/gtk4_extra.css\");\n" p))))))