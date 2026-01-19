(define-module (config home services flatpak)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu packages package-management)
  #:use-module (guix gexp)
  #:export (simple-flatpak-service))

(define (simple-flatpak-service flatpak-list)
  "Return a list of services to manage Flatpaks declaratively, with auto-NVIDIA detection."
  (list
   ;; 1. Automatically handle XDG paths for Flatpak
   (simple-service 'flatpak-env-vars
                   home-environment-variables-service-type
                   `(("XDG_DATA_DIRS" . "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS")))
   (simple-service 'gpu-launch-alias
                home-bash-service-type
                (home-bash-extension
                 (aliases
                  `(("prime-run" . "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia")))))
   ;; 2. The Sync Logic (Install/Update/Prune)
   (simple-service 'flatpak-sync-logic
                   home-run-on-first-login-service-type
                   (list
                    #~(begin
                        (use-modules (ice-9 popen)
                                     (ice-9 rdelim)
                                     (ice-9 regex)
                                     (ice-9 string-fun)
                                     (srfi srfi-1)) ; For 'lset-difference' or list filtering

                        (let* ((flatpak #$(file-append flatpak "/bin/flatpak"))
                               ;; Start with the user's explicit list
                               (base-manifest '#$flatpak-list)
                               
                               ;; --- DYNAMIC NVIDIA DETECTION ---
                               (nvidia-runtime
                                (if (file-exists? "/proc/driver/nvidia/version")
                                    (let* ((content (call-with-input-file "/proc/driver/nvidia/version" read-line))
                                           ;; Regex to capture version (e.g. 535.113.01)
                                           (match (string-match "([0-9]+\\.[0-9]+\\.[0-9]+)" content)))
                                      (if match
                                          (let* ((ver-str (match:substring match 1))
                                                 ;; Convert 535.113.01 -> 535-113-01
                                                 (ver-slug (string-replace-substring ver-str "." "-")))
                                            (format #t "Detected NVIDIA driver: ~a. Adding Flatpak runtime.~%" ver-str)
                                            (string-append "org.freedesktop.Platform.GL.nvidia-" ver-slug))
                                          #f))
                                    #f))
                               
                               ;; Combine explicit list with dynamic nvidia runtime (if found)
                               (manifest (if nvidia-runtime
                                             (cons nvidia-runtime base-manifest)
                                             base-manifest))

                               (get-installed
                                (lambda ()
                                  (let* ((port (open-input-pipe (string-append flatpak " list --user --app --runtime --columns=application")))
                                         (result (let loop ((lines '()))
                                                   (let ((line (read-line port)))
                                                     (if (eof-object? line)
                                                         lines
                                                         (loop (cons line lines)))))))
                                    (close-pipe port)
                                    result))))

                          ;; Ensure flathub is present
                          (system* flatpak "remote-add" "--if-not-exists" "--user"
                                   "flathub" "https://flathub.org/repo/flathub.flatpakrepo")

                          ;; Install/Update items in manifest
                          (for-each (lambda (app)
                                      ;; We use --or-update so it pulls the new version if available
                                      (system* flatpak "install" "--user" "-y" "--or-update" "flathub" app))
                                    manifest)

                          ;; Remove items NOT in manifest
                          ;; Note: We added nvidia-runtime to 'manifest' so it won't be pruned.
                          (let ((installed (get-installed)))
                            (for-each (lambda (app)
                                        (unless (member app manifest)
                                          ;; Be careful not to delete base runtimes (like Freedesktop Platform) 
                                          ;; unless you are sure you want strict declarative management. 
                                          ;; A safer check is often to only prune apps, not runtimes, 
                                          ;; but assuming you want clean declarative state:
                                          
                                          ;; EXTRA SAFETY: Don't prune the NVIDIA runtime if we just missed detection 
                                          ;; (e.g. if you booted with Intel this time but want to keep the driver).
                                          ;; But for strict sync, we prune.
                                          
                                          (format #t "Pruning unmanaged Flatpak: ~a~%" app)
                                          (system* flatpak "uninstall" "--user" "-y" app)))
                                      installed))

                          ;; Cleanup unused runtimes (this cleans up OLD nvidia drivers)
                          (system* flatpak "uninstall" "--user" "--unused" "-y")))))))
