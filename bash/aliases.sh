# shellcheck shell=bash
# Linked to ~/.bash_aliases by install.sh

# ls / grep
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# navigation
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cls='clear'

# repos / tools
alias v='nvim'

export EDITOR=nvim
export VISUAL=nvim
