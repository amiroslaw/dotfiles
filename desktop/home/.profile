# device specific

#Set our umask
umask 022
# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP
# Man is much better than us at figuring this out
unset MANPATH

# Set our default path
export SELENIUM="$HOME/Ext/selenium/chromedriver"
export GRAALVM_HOME="$HOME/.sdkman/candidates/java/21.1.0.r16-grl"
PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin:$HOME/.local/share/gem/ruby/2.7.0/bin:$GRAALVM_HOME/bin:$SELENIUM"
export PATH

# paths
export TOR_WATCH="$HOME/Downloads/.torrenty"
export TOR_DIR="/media/multi/Downloads"
export NOTE="$HOME/Documents/notebook"
export CONFIG="$HOME/Documents/Ustawienia"
export PRIVATE="$HOME/Documents/Ustawienia/stow-private"
export USER_HOME="/home/miro"
export GUI_EDITOR=/usr/bin/nvim-qt
export BACKUP_LOG="$HOME/Documents/Ustawienia/logs/borg-pc"
export BACKUP="/media/winD/backup-borg/daily"
export COURSES="/media/multimedia/kursy"
# Default Apps
export READER="zathura"
export TERMINAL="wezterm"
export TERM_DEF="wezterm"
export TERM_LT="st"
export BROWSER="qutebrowser"
export VIDEO="smplayer"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"

# vars
export CLIPSTER_HISTORY_SIZE=1000

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

if [ -f "$HOME/.zshenv" ] && [ -f "$HOME/.zprofile" ]; then
	. "$HOME/.zshenv"
	. "$HOME/.zprofile"
else
	echo "Failed to find ~/.zshenv or ~/.zprofile"
fi
