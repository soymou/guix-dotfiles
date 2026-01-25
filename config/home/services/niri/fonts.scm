(define-module (config home services niri fonts)
  #:use-module (guix packages)
  #:use-module (guix build-system font)
  #:use-module (guix gexp)
  #:export (font-material-symbols-rounded
            font-roboto-flex
            font-jetbrains-mono-nerd))

(define font-material-symbols-rounded
  (package
    (name "font-material-symbols-rounded") (version "v")
    (source (local-file "/home/mou/.local/share/fonts/MaterialSymbolsRounded.ttf"))
    (build-system font-build-system) (home-page "") (synopsis "f") (description "") (license #f)))

(define font-roboto-flex
  (package
    (name "font-roboto-flex") (version "v")
    (source (local-file "/home/mou/.local/share/fonts/RobotoFlex.ttf"))
    (build-system font-build-system) (home-page "") (synopsis "f") (description "") (license #f)))

(define font-jetbrains-mono-nerd
  (package
    (name "font-jetbrains-mono-nerd") (version "3.0.0")
    (source (local-file "/home/mou/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf"))
    (build-system font-build-system) (home-page "") (synopsis "f") (description "") (license #f)))
