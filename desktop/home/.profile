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
export XDG_CONFIG_HOME="$HOME/.config"
export GTK2_RC_FILES="$HOME/.config/gtkrc-2.0"
export ROFI="$HOME/.config/rofi/scripts"
export GRAVEYARD="$HOME/.local/share/Trash"
export TOR_WATCH="$HOME/Downloads/.torrenty"
export TOR_DIR="/media/multi/Downloads"
export NOTE="$HOME/Documents/notebook_md"
export PRIVATE="$HOME/Documents/dotfiles/private"
export GUI_EDITOR=/usr/bin/micro-st
export ABDUCO_SOCKET_DIR="$HOME/.config/abduco"
export BACKUP_LOG="$HOME/Documents/Ustawienia/logs/borg-pc"
export BACKUP="/media/winD/backup-borg/daily"
# Default Apps
export USER_HOME="/home/miro"
export EDITOR="nvim"
export READER="zathura"
export VISUAL="nvim"
export TERM="kitty"
export TERM_LT="st"
export BROWSER="firefox"
export VIDEO="smplayer"
export IMAGE="sxiv"
export OPENER="xdg-open"
export PAGER="less"
export WM="bspwm"
export MPD_PORT=6666
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"

# vars
CLIPSTER_HISTORY_SIZE=1000
