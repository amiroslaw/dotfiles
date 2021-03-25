#!/bin/sh

[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults

## To enable pulseaufio, uncomment this and run sudo pacman -S pavucontrol pulseaudio-ctl manjaro-pulse
# systemctl --user enable pulseaudio && systemctl --user start pulseaudio &

userresources=$HOME/.config/Xresources
usermodmap=$HOME/.config/Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi
# if [ $TERM = linux ] || [ -e "/etc/systemd/system/graphical.target.wants/xlogin@$(whoami).service" ] ; then

exec dbus-launch --sh-syntax --exit-with-session bspwm
# exec bspwm
