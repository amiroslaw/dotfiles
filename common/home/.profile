# general

#Set our umask
umask 022
# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP
# Man is much better than us at figuring this out
unset MANPATH

# Set our default path
export SELENIUM="$HOME/Ext/selenium/chromedriver"
# PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin:$HOME/.local/share/gem/ruby/2.7.0/bin:$SELENIUM"
export GRAALVM_HOME="$HOME/.local/share/sdkman/candidates/java/23.1.1.r21-nik"
PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin:$HOME/.local/share/gem/ruby/2.7.0/bin:$GRAALVM_HOME/bin:$SELENIUM:$(go env GOPATH)/bin"
export PATH

export NIK=~/.local/share/sdkman/candidates/java/23.r20-nik/bin/native-image
export NIK_HOME=~/.local/share/sdkman/candidates/java/23.r20-nik

# paths
export ROFI="$HOME/.config/rofi/scripts"
export GRAVEYARD="$HOME/.local/share/Trash"
export SCRIPTS="$HOME/Documents/dotfiles/common/scripts/.bin"
export LUA_INIT="@$HOME/Documents/dotfiles/common/scripts/.bin/lua/init.lua"
export BABASHKA_PRELOADS='(load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))'
export ZPLUG_HOME=~/.config/zplug

# Default Apps
export EDITOR="nvim"
export VISUAL="nvim"
export GUI_EDITOR=/usr/bin/nvim-qt
export OPENER="xdg-open"
export PAGER="less"
export MANPAGER="nvim +Man!"
# TERM is not available 
export TERMINAL="wezterm"
export TERM_FONT=" --config font_size=%d "
export TERM_RUN=' start --class "%s" -- %s '
export TERM_LT="xst"
export TERM_LT_FONT=" -f 'UbuntuMono Nerd Font:size=%d' "
export TERM_LT_RUN=' -n "%s" -e %s'
export BROWSER="qutebrowser"
# export BROWSER="org.qutebrowser.qutebrowser.desktop"
export READER="zathura"
export DOWNGRADE_FROM_ALA=1

# for my scripts
export VIDEO="smplayer"
export IMAGE="pqiv"
export GAMIFICATION="/home/miro/Documents/Ustawienia/configs/grywalizacja"
export OLLAMA_MODELS="$HOME/Ext/ollama"
export OLLAMA_HOST=":11434"

# configs
export XDG_CONFIG_DIRS=/usr/etc/xdg:/etc/xdg
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export QT_QPA_PLATFORMTHEME="qt5ct"
export WM="bspwm"
export PANEL_FIFO="/tmp/panel-fifo"
export PANEL_FIFO PANEL_HEIGHT PANEL_FONT_FAMILY
export BSPWM_SOCKET="/tmp/bspwm-socket"
export MPD_PORT=6666
export CLIPSTER_HISTORY_SIZE=1000
export GTK2_RC_FILES="/home/miro/.config/gtkrc-2.0"
# export GTK3_RC_FILES=/home/miro/.config/gtkrc-3.0

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
# load zsh files
if [ -f "$HOME/.zshenv" ] && [ -f "$HOME/.zprofile" ]; then
	. "$HOME/.zshenv"
	. "$HOME/.zprofile"
else
	echo "Failed to find ~/.zshenv or ~/.zprofile"
fi

#[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec starx
# Following automatically calls "startx" when you login:
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx -- -keeptty -nolisten tcp > ~/.xorg.log 2>&1

# fix java apps with bspwm
export _JAVA_AWT_WM_NONREPARENTING=1
if [ -n "`which wmname`" ]; then
    wmname LG3D
fi
