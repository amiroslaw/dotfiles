# $HOME/.profile

#Set our umask
umask 022

# Set our default path
PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin"
export PATH

# Load profiles from /etc/profile.d
if test -d /etc/profile.d/; then
	for profile in /etc/profile.d/*.sh; do
		test -r "$profile" && . "$profile"
	done
	unset profile
fi

# Source global bash config
if test "$PS1" && test "$BASH" && test -r /etc/bash.bashrc; then
	. /etc/bash.bashrc
fi

# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH



# paths
export CONFIG="$HOME/Documents/Ustawienia"
export ROFI="$HOME/.config/rofi/scripts"
export GRAVEYARD="$HOME/.local/share/Trash"
export TOR_WATCH="$HOME/Downloads/.torrenty"
export TOR_DIR="/media/multi/Downloads"
export NOTE="$HOME/Documents/notebook"
export PRIVATE="$HOME/Documents/Ustawienia/stow-private"

# Default Apps
export USER_HOME="/home/miro"
export EDITOR="nvim"
export READER="zathura"
export GUI_EDITOR=/usr/bin/micro-st
export VISUAL="nvim"
export TERM_DEF="wezterm"
export TERM_LT="st"
# export BROWSER="org.qutebrowser.qutebrowser.desktop"
export BROWSER="qutebrowser"
export VIDEO="smplayer"
export IMAGE="sxiv"
export OPENER="xdg-open"
export PAGER="less"
export WM="bspwm"
export MPD_PORT=6666
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
export BSPWM_SOCKET="/tmp/bspwm-socket"
# export LANGUAGE=en_US.UTF-8
# export LANG=en_US.UTF-8
# export LC_CTYPE=en_US.UTF-8
# export LC_ALL=C
export LC_ALL=en_US.UTF-8

# vars
CLIPSTER_HISTORY_SIZE=1000

# if [[ "$(tty)" = "/dev/tty1" ]]; then
#	pgrep bspwm || startx
# fi

