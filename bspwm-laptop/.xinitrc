#!/bin/sh

[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults

## To enable pulseaufio, uncomment this and run sudo pacman -S pavucontrol pulseaudio-ctl manjaro-pulse
systemctl --user enable pulseaudio && systemctl --user start pulseaudio
# /usr/bin/start-pulseaudio-x11 &
# pulseaudio --start --verbose &
#sleep 2s && volume 37 &
 # sleep 10 && pulseaudio -k &
 # sleep 10 && pulseaudio -D &
 # sleep 10 && pulseaudio --start &

# pulseaudio -k &
# pulseaudio -D &
# pulseaudio --start &

userresources=$HOME/.Xresources

# merge in defaults and keymaps
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

# xrdb merge .Xresources &

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# for file in /etc/profile ${HOME}/.profile ${HOME}/.config/bspwm/autostart ; do
# 	[ -r "${file}" ] && . "${file}"
# done


# if [ $TERM = linux ] || [ -e "/etc/systemd/system/graphical.target.wants/xlogin@$(whoami).service" ] ; then
# dbus-launch --sh-syntax --exit-with-session bspwm-session
# fi

## Load appearance settings
export GTK2_RC_FILES="$HOME/.gtkrc-2.0" &
## compositing. Required for shadows, transparency and stuff. 
## Reduces flicker. Disabling saves resources.
picom --experimental-backends &
sh ~/.fehbg &
#nitrogen --restore &
# cursor 
xsetroot -cursor_name left_ptr &
## hides mouse when you are not using it. When mouse is hidden, rootmenu considers mouse on desktop, so actions can be triggered.
##run_once is a script in /usr/bin that prevents running script if it is running already
run_once unclutter &

## enable local fonts in .fonts directory
xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/misc &
xset +fp ~/.fonts &
xset fp rehash &
fc-cache -fv &

## Automount removable media
devmon &
# udiskie &

## powersaving options
xset s off &
xset s noblank &
xset s noexpose &
xset c on &
xset -dpms &
xbacklight -set 15 &

## Run screenlock when suspending
i3lock-wait-for-suspend &
## multimonitor support. Save monitor configurations with "autorandr.sh --save <profile>"
srandrd atorandr.sh --change
## Notify about package updates
# update-checker 7200 &
# dbus-launch gsettings set org.mate.NotificationDaemon theme 'slider' && sed -i '/gsettings/d' ~/.config/bspwm/autostart &
#lxpolkit &
polybar main -c $HOME/.config/polybar/configlap &
#sleep 2s && bspc config top_padding 10 &

#easystroke &
sleep 500 && megasync &
#clipit &
clipster -d &
#tmux new-session -d -s tor rtorrent &
redshift -l 51.2:22.6 &


exec bspwm
