(define-module (config home services niri packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages image)
  #:use-module (gnu packages image-processing)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages music)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages kde-utils)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages web)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages video)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages base)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (config home services niri fonts)
  #:export (magick-wrapper
            %niri-packages))

(define magick-wrapper
  (package
    (name "magick-wrapper") (version "0.1") (source #f) (build-system trivial-build-system)
    (arguments
     (list #:builder
           #~(begin
               (mkdir #$output) (mkdir (string-append #$output "/bin"))
               (let ((m (string-append #$output "/bin/magick"))) 
                 (call-with-output-file m
                   (lambda (p) (display "#!/bin/sh
if [ \"$1\" = \"identify\" ]; then
  shift
  exec identify \"$@\"
fi
exec convert \"$@\"
" p)))
                 (chmod m #o755))))) 
    (inputs (list imagemagick)) (propagated-inputs (list imagemagick)) (home-page "") (synopsis "m") (description "") (license #f)))

(define %niri-packages
  (list niri xwayland-satellite quickshell qtwayland qt5compat kirigami ksyntaxhighlighting
        ninja pkg-config cairo gobject-introspection glib (list glib "bin") dbus
        gcc-toolchain linux-libre-headers
        python-pillow python-numpy python-psutil python-tqdm python-loguru python-click
        python-pygobject python-pycairo python-dbus-python opencv
        fuzzel swaylock swayidle mako waybar wl-clipboard cliphist grim slurp swappy
        wlsunset brightnessctl playerctl kitty polkit-gnome adwaita-icon-theme
        hicolor-icon-theme imagemagick magick-wrapper jq matugen sassc
        pipewire wireplumber bc kdialog hyprpicker xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr libnotify mpvpaper ffmpeg
        font-material-symbols-rounded font-roboto-flex font-jetbrains-mono-nerd
        font-awesome foot fish starship eza bat))