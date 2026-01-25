(define-module (config home services niri niri)
  #:use-module (guix gexp)
  #:export (niri-config-patch))

(define niri-config (local-file "configs/config.kdl"))

(define (niri-config-patch)
  #~(let ((f (string-append #$output "/dots/.config/niri/config.kdl")))
      (mkdir-p (dirname f))
      (copy-file #$niri-config f)
      (make-file-writable f)
      (substitute* f
        (("spawn-at-startup \"qs\" \"-c\" \"ii\"")
         "spawn-at-startup \"pipewire\"\nspawn-at-startup \"wireplumber\"\nspawn-at-startup \"bash\" \"-c\" \"sleep 1 && ~/.config/quickshell/ii/scripts/ii-setup.sh\"\nspawn-at-startup \"bash\" \"-c\" \"sleep 2 && qs -c ii\""))))