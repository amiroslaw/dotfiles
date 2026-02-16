#!/bin/sh

[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults


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
# exec dbus-launch --sh-syntax --exit-with-session bspwm
# exec dbus-run-session -- bspwm - raczej nie
# exec dbus-launch --exit-with-x11 bspwm
# - no dbus socket but with export $(dbus-launch) in autostart

# https://github.com/netblue30/firejail/issues/3769[Firefox DBus user socket was not found · Issue #3769 · netblue30/firejail]
# exec dbus-launch --exit-with-session bash <<EOF
# # start dbus and set his envs
# export $(dbus-launch)
# exec bspwm 
# EOF

exec dbus-launch --exit-with-session ~/.config/bspwm/autostart 
