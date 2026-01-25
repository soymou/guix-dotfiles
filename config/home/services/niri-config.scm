(define-module (config home services niri-config)
  #:use-module (gnu home services)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services sound)
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
  #:use-module (guix gexp)
  #:use-module (guix git)
  #:use-module (guix download)
  #:use-module (guix build-system font)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 textual-ports)
  #:export (niri-config-service
            niri-config-from-git
            %inir-fontconfig))

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

(define magick-wrapper
  (package
    (name "magick-wrapper") (version "0.1") (source #f) (build-system trivial-build-system)
    (arguments
     (list #:builder
           #~(begin
               (mkdir #$output) (mkdir (string-append #$output "/bin"))
               (let ((m (string-append #$output "/bin/magick")))
                 (call-with-output-file m
                   (lambda (p) (display "#!/bin/sh\nif [ \"$1\" = \"identify\" ]; then\n  shift\n  exec identify \"$@\"
fi\nexec convert \"$@\"
" p)))
                 (chmod m #o755)))))
    (inputs (list imagemagick)) (propagated-inputs (list imagemagick)) (home-page "") (synopsis "m") (description "") (license #f)))

(define inir-source (local-file "/home/mou/Desktop/Personal/dotfiles/iNiR" #:recursive? #t))

(define inir-checkout
  (computed-file "patched-inir"
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils) (ice-9 rdelim) (ice-9 textual-ports))
          (copy-recursively #$inir-source #$output)
          (let ((files (find-files #$output "[.](qml|js|json|kdl|sh|fish|py)$"))
                (sed (string-append #$sed "/bin/sed")))
            (for-each make-file-writable files)
            (for-each (lambda (f)
                        (invoke sed "-i" "s|/usr/bin/jq|jq|g" f)
                        (invoke sed "-i" "s|/usr/bin/||g" f)
                        (invoke sed "-i" "s|Process.exec|Quickshell.execDetached|g" f)
                        (unless (or (string-suffix? "Config.qml" f) (string-suffix? ".py" f))
                           (invoke sed "-i" "s|kitty|foot|g" f)
                           (invoke sed "-i" "s|ghostty|foot|g" f))
                        (invoke sed "-i" "s|^#!env |#!/usr/bin/env |g" f)
                        (invoke sed "-i" "s|#!/usr/bin/fish|#!/usr/bin/env fish|g" f)
                        (invoke sed "-i" "s|#!/bin/bash|#!/usr/bin/env bash|g" f))
                      files)
            (let ((f (string-append #$output "/modules/common/Config.qml")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|\"ghostty\"|\"foot\"|g" f)
                  (invoke sed "-i" "s|\"kitty\"|\"foot\"|g" f)
                  (invoke sed "-i" "s|: \"kitty |: \"foot |g" f)
                  (invoke sed "-i" "s|: \"ghostty |: \"foot |g" f)))
            (let ((f (string-append #$output "/services/ThemeService.qml")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|Quickshell.execDetached.Directories.wallpaperSwitchScriptPath, .--noswitch..|Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, \"--noswitch\", \"--mode\", (Config.options?.appearance?.customTheme?.darkmode ?? true) ? \"dark\" : \"light\"])|g" f)))
            (let ((f (string-append #$output "/scripts/colors/applycolor.sh")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|cp .SCRIPT_DIR/terminal/sequences.txt.|install -m 644 \"$SCRIPT_DIR/terminal/sequences.txt\"|g" f)))
            (let ((f (string-append #$output "/scripts/colors/apply-gtk-theme.sh")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|GTK4_CSS=.HOME/.config/gtk-4.0/gtk.css.|GTK4_CSS=\"/home/mou/.cache/matugen/gtk4_extra.css\"|g" f)
                  (invoke sed "-i" "s|GTK3_CSS=.HOME/.config/gtk-3.0/gtk.css.|GTK3_CSS=\"/home/mou/.cache/matugen/gtk3_extra.css\"|g" f)))
            (let ((f (string-append #$output "/scripts/colors/switchwall.sh")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|cat . .RESTORE_SCRIPT.tmp.|mkdir -p \"$(dirname \"$RESTORE_SCRIPT\")\"; cat > \"$RESTORE_SCRIPT.tmp\"|g" f)))
            (let ((f (string-append #$output "/scripts/colors/generate_terminal_configs.py")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|f..home./.config/foot/current-theme.conf.|os.path.expanduser(\"~/.cache/matugen/foot.ini\")|g" f)
                  (invoke sed "-i" "s|f..home./.config/foot/colors.ini.|os.path.expanduser(\"~/.cache/matugen/foot.ini\")|g" f)
                  (invoke sed "-i" "s|if ensure_line_in_file.|if False and ensure_line_in_file(|g" f)))
            ;; Fix shebang in generate_colors_material.py to work on Guix (no /bin/sh)
            (let ((f (string-append #$output "/scripts/colors/generate_colors_material.py")))
               (when (file-exists? f)
                  (invoke sed "-i" "1s|.*|#!/usr/bin/env python3|" f)))
            ;; Create ii-setup.sh script for venv initialization
            (let ((f (string-append #$output "/scripts/ii-setup.sh")))
               (call-with-output-file f
                 (lambda (p)
                   (display "#!/usr/bin/env bash
# ii-setup.sh - Initialize Python virtual environment for iNiR/illogical-impulse
# This script sets up the materialyoucolor library needed for theme generation

set -e

VENV_DIR=\"${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-$HOME/.local/state/quickshell/.venv}\"
STATE_DIR=\"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell\"
CACHE_DIR=\"${XDG_CACHE_HOME:-$HOME/.cache}\"

# Create necessary directories
mkdir -p \"$STATE_DIR/user/generated\"
mkdir -p \"$CACHE_DIR/matugen\"

# Create venv if it doesn't exist or is broken
if [ ! -f \"$VENV_DIR/bin/python\" ]; then
    echo \"[ii-setup] Creating Python virtual environment at $VENV_DIR\"
    python3 -m venv \"$VENV_DIR\"
fi

# Check if materialyoucolor is installed
if ! \"$VENV_DIR/bin/python\" -c \"import materialyoucolor\" 2>/dev/null; then
    echo \"[ii-setup] Installing materialyoucolor and dependencies...\"
    \"$VENV_DIR/bin/pip\" install --quiet materialyoucolor pillow
fi

echo \"[ii-setup] Python environment ready\"
" p)))
               (chmod f #o755))
            ;; Patch niri config to run setup script and wait for pipewire
            (let ((f (string-append #$output "/dots/.config/niri/config.kdl")))
               (when (file-exists? f)
                  (substitute* f
                    (("spawn-at-startup \"qs\" \"-c\" \"ii\"")
                     "spawn-at-startup \"pipewire\"\nspawn-at-startup \"wireplumber\"\nspawn-at-startup \"bash\" \"-c\" \"sleep 1 && ~/.config/quickshell/ii/scripts/ii-setup.sh\"\nspawn-at-startup \"bash\" \"-c\" \"sleep 2 && qs -c ii\""))))
            (let ((d (string-append #$output "/dots/.config/foot")))
               (mkdir-p d)
               (call-with-output-file (string-append d "/foot.ini")
                 (lambda (p) (display "[main]
include=/home/mou/.cache/matugen/foot.ini
shell=fish
term=xterm-256color
font=JetBrainsMono Nerd Font:size=11
pad=25x25

[cursor]
style=beam
blink=no
beam-thickness=1.5

[scrollback]
lines=10000
indicator-position=relative

[key-bindings]
scrollback-up-page=Control+Shift+Page_Up
scrollback-down-page=Control+Shift+Page_Down
clipboard-copy=Control+Shift+c
clipboard-paste=Control+Shift+v
font-increase=Control+plus Control+equal
font-decrease=Control+minus
font-reset=Control+0
" p))))
            (let ((f (string-append #$output "/dots/.config/matugen/config.toml")))
               (when (file-exists? f)
                  (invoke sed "-i" "s|output_path = '~/.config/fuzzel/fuzzel_theme.ini'|output_path = '~/.cache/matugen/fuzzel.ini'|g" f)
                  (invoke sed "-i" "s|output_path = '~/.config/gtk-3.0/gtk.css'|output_path = '~/.cache/matugen/gtk3.css'|g" f)
                  (invoke sed "-i" "s|output_path = '~/.config/gtk-4.0/gtk.css'|output_path = '~/.cache/matugen/gtk4.css'|g" f)
                  ;; Add starship template to matugen config
                  (let ((content (call-with-input-file f get-string-all)))
                    (make-file-writable f)
                    (call-with-output-file f
                      (lambda (p)
                        (display content p)
                        (display "
# Starship prompt theme (Material You)
[templates.starship]
input_path = '~/.config/matugen/templates/starship/starship.toml'
output_path = '~/.cache/matugen/starship.toml'
" p))))))
            (let ((f (string-append #$output "/dots/.config/fuzzel/fuzzel.ini")))
               (when (file-exists? f)
                  (make-file-writable f)
                  (let ((c (call-with-input-file f get-string-all)))
                    (call-with-output-file f
                      (lambda (p) (display c p) (display "\ninclude=~/.cache/matugen/fuzzel.ini\n" p))))))
            (let ((g3 (string-append #$output "/dots/.config/gtk-3.0/gtk.css"))
                  (g4 (string-append #$output "/dots/.config/gtk-4.0/gtk.css")))
               (when (file-exists? g3) (make-file-writable g3))
               (when (file-exists? g4) (make-file-writable g4))
               (call-with-output-file g3 (lambda (p) (display "@import url(\"file:///home/mou/.cache/matugen/gtk3.css\");\n@import url(\"file:///home/mou/.cache/matugen/gtk3_extra.css\");\n" p)))
               (call-with-output-file g4 (lambda (p) (display "@import url(\"file:///home/mou/.cache/matugen/gtk4.css\");\n@import url(\"file:///home/mou/.cache/matugen/gtk4_extra.css\");\n" p))))
            ;; Starship matugen template (Material You colors)
            (let ((d (string-append #$output "/defaults/matugen/templates/starship")))
               (mkdir-p d)
               (call-with-output-file (string-append d "/starship.toml")
                 (lambda (p) (display "# Material You Starship Theme - Generated by Matugen
format = '''
[](fg:surface_container)$os$username[](fg:surface_container bg:surface_container_high)$directory[](fg:surface_container_high bg:surface_variant)$git_branch$git_status[](fg:surface_variant bg:secondary_container)$c$rust$golang$nodejs$php$java$kotlin$python[](fg:secondary_container bg:primary_container)$docker_context$conda[](fg:primary_container)$fill[](fg:tertiary_container)$cmd_duration[](fg:tertiary_container bg:primary)$time[ ](fg:primary)
$character'''

palette = 'material_you'

[palettes.material_you]
primary = '#{{colors.primary.default.hex_stripped}}'
on_primary = '#{{colors.on_primary.default.hex_stripped}}'
primary_container = '#{{colors.primary_container.default.hex_stripped}}'
on_primary_container = '#{{colors.on_primary_container.default.hex_stripped}}'
secondary = '#{{colors.secondary.default.hex_stripped}}'
on_secondary = '#{{colors.on_secondary.default.hex_stripped}}'
secondary_container = '#{{colors.secondary_container.default.hex_stripped}}'
on_secondary_container = '#{{colors.on_secondary_container.default.hex_stripped}}'
tertiary = '#{{colors.tertiary.default.hex_stripped}}'
on_tertiary = '#{{colors.on_tertiary.default.hex_stripped}}'
tertiary_container = '#{{colors.tertiary_container.default.hex_stripped}}'
on_tertiary_container = '#{{colors.on_tertiary_container.default.hex_stripped}}'
error = '#{{colors.error.default.hex_stripped}}'
on_error = '#{{colors.on_error.default.hex_stripped}}'
background = '#{{colors.background.default.hex_stripped}}'
on_background = '#{{colors.on_background.default.hex_stripped}}'
surface = '#{{colors.surface.default.hex_stripped}}'
on_surface = '#{{colors.on_surface.default.hex_stripped}}'
surface_variant = '#{{colors.surface_variant.default.hex_stripped}}'
on_surface_variant = '#{{colors.on_surface_variant.default.hex_stripped}}'
surface_container = '#{{colors.surface_container.default.hex_stripped}}'
surface_container_high = '#{{colors.surface_container_high.default.hex_stripped}}'
surface_container_highest = '#{{colors.surface_container_highest.default.hex_stripped}}'
outline = '#{{colors.outline.default.hex_stripped}}'
outline_variant = '#{{colors.outline_variant.default.hex_stripped}}'

[os]
disabled = false
style = 'bg:surface_container fg:on_surface'
format = '[$symbol ]($style)'

[os.symbols]
Alpaquita = ''
Alpine = ''
Amazon = ''
Android = ''
Arch = '󰣇'
Artix = ''
CentOS = ''
Debian = ''
DragonFly = ''
Emscripten = ''
EndeavourOS = ''
Fedora = ''
FreeBSD = ''
Garuda = '󰛓'
Gentoo = ''
HardenedBSD = '󰞌'
Illumos = '󰈸'
Linux = ''
Mabox = ''
Macos = ''
Manjaro = ''
Mariner = ''
MidnightBSD = ''
Mint = ''
NetBSD = ''
NixOS = ''
OpenBSD = '󰈺'
openSUSE = ''
OracleLinux = '󰌷'
Pop = ''
Raspbian = ''
Redhat = ''
RedHatEnterprise = ''
Redox = '󰀘'
Solus = '󰠳'
SUSE = ''
Ubuntu = ''
Unknown = ''
Windows = '󰍲'

[username]
show_always = true
style_user = 'bg:surface_container fg:on_surface'
style_root = 'bg:surface_container fg:error'
format = '[$user]($style)'

[directory]
style = 'bg:surface_container_high fg:on_surface'
format = '[ $path ]($style)'
truncation_length = 3
truncation_symbol = '…/'

[directory.substitutions]
'Documents' = '󰈙 '
'Downloads' = ' '
'Music' = '󰝚 '
'Pictures' = ' '
'Developer' = '󰲋 '

[git_branch]
symbol = ''
style = 'bg:surface_variant fg:on_surface_variant'
format = '[ $symbol $branch ]($style)'

[git_status]
style = 'bg:surface_variant fg:on_surface_variant'
format = '[$all_status$ahead_behind ]($style)'

[c]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[rust]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[golang]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[nodejs]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[php]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[java]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[kotlin]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[python]
symbol = ''
style = 'bg:secondary_container fg:on_secondary_container'
format = '[ $symbol( $version) ]($style)'

[docker_context]
symbol = ''
style = 'bg:primary_container fg:on_primary_container'
format = '[ $symbol( $context) ]($style)'

[conda]
style = 'bg:primary_container fg:on_primary_container'
format = '[ $symbol( $environment) ]($style)'

[fill]
symbol = ' '

[cmd_duration]
min_time = 500
style = 'bg:tertiary_container fg:on_tertiary_container'
format = '[󱎫 $duration ]($style)'

[time]
disabled = false
time_format = '%R'
style = 'bg:primary fg:on_primary'
format = '[ $time ]($style)'

[character]
success_symbol = '[❯](bold primary)'
error_symbol = '[❯](bold error)'
" p))))
            ;; Fish config with starship (Material You)
            (let ((d (string-append #$output "/dots/.config/fish")))
               (mkdir-p d)
               (call-with-output-file (string-append d "/config.fish")
                 (lambda (p) (display "# Fish shell configuration

# Initialize starship prompt with Material You theme
set -gx STARSHIP_CONFIG ~/.cache/matugen/starship.toml
starship init fish | source

# Environment
set -gx EDITOR emacs
set -gx VISUAL emacs

# Modern ls with icons (if eza/exa available)
if command -v eza > /dev/null
    alias ls 'eza --icons --group-directories-first'
    alias ll 'eza -la --icons --group-directories-first --git'
    alias la 'eza -a --icons --group-directories-first'
    alias lt 'eza --tree --icons --level=2'
else
    alias ll 'ls -la'
    alias la 'ls -A'
end

# Git aliases
alias g 'git'
alias gs 'git status -sb'
alias gd 'git diff'
alias gds 'git diff --staged'
alias gc 'git commit'
alias gca 'git commit --amend'
alias gp 'git push'
alias gpl 'git pull'
alias gl 'git log --oneline --graph -15'
alias gco 'git checkout'
alias gb 'git branch'

# Quick navigation
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

# Useful shortcuts
alias c 'clear'
alias e 'emacs'
alias v 'nvim'
alias cat 'bat --style=plain' 2>/dev/null; or alias cat 'cat'

# Fish greeting - Material You style
function fish_greeting
    set_color brblue
    echo '  Welcome to Fish '(set_color brmagenta)'󰈺'(set_color normal)
end

# Colored man pages
set -gx LESS_TERMCAP_mb (printf '\\e[1;32m')
set -gx LESS_TERMCAP_md (printf '\\e[1;32m')
set -gx LESS_TERMCAP_me (printf '\\e[0m')
set -gx LESS_TERMCAP_se (printf '\\e[0m')
set -gx LESS_TERMCAP_so (printf '\\e[01;33m')
set -gx LESS_TERMCAP_ue (printf '\\e[0m')
set -gx LESS_TERMCAP_us (printf '\\e[1;4;31m')
" p)))))))))

(define %inir-fontconfig '((match (@ (target "font")) (edit (@ (name "rgba") (mode "assign")) (const "none")))))

(define %inir-file-mappings
  '(("niri/config.kdl" . "dots/.config/niri/config.kdl") ("fuzzel/fuzzel.ini" . "dots/.config/fuzzel/fuzzel.ini")
    ("foot/foot.ini" . "dots/.config/foot/foot.ini") ("gtk-3.0/settings.ini" . "dots/.config/gtk-3.0/settings.ini")
    ("gtk-4.0/settings.ini" . "dots/.config/gtk-4.0/settings.ini") ("gtk-3.0/gtk.css" . "dots/.config/gtk-3.0/gtk.css")
    ("gtk-4.0/gtk.css" . "dots/.config/gtk-4.0/gtk.css") ("matugen/config.toml" . "dots/.config/matugen/config.toml")
    ("matugen/templates" . "defaults/matugen/templates")
    ("fish/config.fish" . "dots/.config/fish/config.fish")))

(define (make-config-files checkout mappings) (map (match-lambda ((target . source) `(,target ,(file-append checkout "/" source)))) mappings))
(define (make-quickshell-config checkout) `(("quickshell/ii" ,checkout)))

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

(define niri-config-service
  (list (simple-service 'niri-packages home-profile-service-type %niri-packages)
        (simple-service 'niri-config-files home-xdg-configuration-files-service-type (make-config-files inir-checkout %inir-file-mappings))
        (simple-service 'quickshell-ii-config home-xdg-configuration-files-service-type (make-quickshell-config inir-checkout))
        (simple-service 'niri-fontconfig home-fontconfig-service-type %inir-fontconfig)))

(define* (niri-config-from-git #:key repo-url repo-commit (file-mappings %inir-file-mappings) (fontconfig %inir-fontconfig))
  (let ((checkout (git-checkout (url repo-url) (commit repo-commit))))
    (append (list (simple-service 'niri-packages home-profile-service-type %niri-packages)
                  (simple-service 'niri-config-files home-xdg-configuration-files-service-type (make-config-files checkout file-mappings))
                  (simple-service 'quickshell-ii-config home-xdg-configuration-files-service-type (make-quickshell-config checkout)))
            (if fontconfig (list (simple-service 'niri-fontconfig home-fontconfig-service-type fontconfig)) '()))))