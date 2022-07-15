# device specific

#Set our umask
umask 022
# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

# Set our default path
PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin"
export PATH

# paths
export TOR_WATCH="$HOME/Downloads/.torrenty"
export TOR_DIR="/media/multi/Downloads"
export NOTE="$HOME/Documents/notebook"
export CONFIG="$HOME/Documents/Ustawienia"
export PRIVATE="$HOME/Documents/Ustawienia/stow-private"
export USER_HOME="/home/miro"

# Default Apps
export READER="zathura"
export GUI_EDITOR=/usr/bin/micro-st
export TERMINAL="wezterm"
export TERM_DEF="wezterm"
export TERM_LT="st"
# export BROWSER="org.qutebrowser.qutebrowser.desktop"
export BROWSER="qutebrowser"
export VIDEO="smplayer"
export IMAGE="sxiv"
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
# export LANGUAGE=en_US.UTF-8
# export LANG=en_US.UTF-8
# export LC_CTYPE=en_US.UTF-8
# export LC_ALL=C
export LC_ALL=en_US.UTF-8

# vars
export CLIPSTER_HISTORY_SIZE=1000

# if [[ "$(tty)" = "/dev/tty1" ]]; then
#	pgrep bspwm || startx
# fi

# Source global bash config
if test "$PS1" && test "$BASH" && test -r /etc/bash.bashrc; then
	. /etc/bash.bashrc
fi

if [ -f "$HOME/.zshenv" ] && [ -f "$HOME/.zprofile" ]; then
	. "$HOME/.zshenv"
	. "$HOME/.zprofile"
else
	echo "Failed to find ~/.zshenv or ~/.zprofile"
fi
