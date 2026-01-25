(define-module (config home services niri matugen)
  #:use-module (guix gexp)
  #:use-module (gnu packages base)
  #:use-module (ice-9 textual-ports)
  #:export (matugen-config-patch))

(define matugen-config (local-file "configs/matugen-config.toml"))

(define (matugen-config-patch)
  #~(let ((f (string-append #$output "/dots/.config/matugen/config.toml"))
          (sed-bin (string-append #$sed "/bin/sed")))
      (mkdir-p (dirname f))
      (copy-file #$matugen-config f)
      (make-file-writable f)
      (invoke sed-bin "-i" "s|output_path = '~/.config/fuzzel/fuzzel_theme.ini'|output_path = '~/.cache/matugen/fuzzel.ini'|g" f)
      (invoke sed-bin "-i" "s|output_path = '~/.config/gtk-3.0/gtk.css'|output_path = '~/.cache/matugen/gtk3.css'|g" f)
      (invoke sed-bin "-i" "s|output_path = '~/.config/gtk-4.0/gtk.css'|output_path = '~/.cache/matugen/gtk4.css'|g" f)
      ;; Add starship template to matugen config
      (let ((content (call-with-input-file f get-string-all)))
        (call-with-output-file f
          (lambda (p)
            (display content p)
            (display "
# Starship prompt theme (Material You)
[templates.starship]
input_path = '~/.config/matugen/templates/starship/starship.toml'
output_path = '~/.cache/matugen/starship.toml'
" p))))))