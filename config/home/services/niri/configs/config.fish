# Fish shell configuration

# Initialize starship prompt with Material You theme
set -gx STARSHIP_CONFIG ~/.cache/matugen/starship.toml
starship init fish | source

# Environment
set -gx EDITOR emacs
set -gx VISUAL emacs
set -gx PATH $HOME/.config/guix/current/bin

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
set -gx LESS_TERMCAP_mb (printf '\e[1;32m')
set -gx LESS_TERMCAP_md (printf '\e[1;32m')
set -gx LESS_TERMCAP_me (printf '\e[0m')
set -gx LESS_TERMCAP_se (printf '\e[0m')
set -gx LESS_TERMCAP_so (printf '\e[01;33m')
set -gx LESS_TERMCAP_ue (printf '\e[0m')
set -gx LESS_TERMCAP_us (printf '\e[1;4;31m')
