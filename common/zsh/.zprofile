# general

PATH="/usr/local/sbin:/usr/bin/core_perl:/usr/local/bin:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin"
#PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin:$HOME/.local/bin:/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:~/.gem/ruby/2.6.0/bin"
export PATH

export XDG_CONFIG_HOME="$HOME/.config"
export BSPWM_SOCKET="/tmp/bspwm-socket"
export XDG_CONFIG_DIRS=/usr/etc/xdg:/etc/xdg
export QT_QPA_PLATFORMTHEME="qt5ct"
export PANEL_FIFO="/tmp/panel-fifo"
export PANEL_FIFO PANEL_HEIGHT PANEL_FONT_FAMILY
export ZPLUG_HOME=~/.config/zplug
## Load appearance settings
export GTK2_RC_FILES="$HOME/.config/gtkrc-2.0"

source $HOME/.profile

#[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec starx
# Following automatically calls "startx" when you login:
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx -- -keeptty -nolisten tcp > ~/.xorg.log 2>&1

# fix java apps with bspwm
export _JAVA_AWT_WM_NONREPARENTING=1
if [ -n "`which wmname`" ]; then
    wmname LG3D
fi
