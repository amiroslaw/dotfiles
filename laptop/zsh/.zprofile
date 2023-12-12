# device specific

# paths
export TOR_WATCH="$HOME/Downloads/.torrenty"
export TOR_DIR="/media/multi/Downloads"
export NOTE="$HOME/Documents/notebook"
export CONFIG="$HOME/Documents/Ustawienia"
export PRIVATE="$HOME/Documents/Ustawienia/stow-private"
export USER_HOME="/home/miro"
# export OLLAMA_API_HOST="http://192.168.1.32:11434"
export OLLAMA_API_HOST="http://$(cat "$PRIVATE/ip4pc"):11434"


# Default Apps
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
# export LANGUAGE=en_US.UTF-8
# export LANG=en_US.UTF-8
# export LC_CTYPE=en_US.UTF-8
# export LC_ALL=C
export LC_ALL=en_US.UTF-8

bindkey -e

# if [[ "$(tty)" = "/dev/tty1" ]]; then
#	pgrep bspwm || startx
# fi

