#!/usr/bin/env sh

# Terminate already running instances of the bar
killall -q polybar
# FOR 1 MONITOR
# DISPLAY1="$(xrandr -q | grep 'eDP1\|VGA-1\|DP-1' | cut -d ' ' -f1)"
# [[ ! -z "$DISPLAY1" ]] && MONITOR="$DISPLAY1" polybar ext &

# DISPLAY2="$(xrandr -q | grep 'HDMI1\|DVI-D-0\|DVI-D-1' | cut -d ' ' -f1)"
# [[ ! -z $DISPLAY2 ]] && MONITOR=$DISPLAY2 polybar main &
# lub
# for i in $(polybar -m | awk -F: '{print $1}'); do MONITOR=$i polybar main -c ~/.config/polybar/config & done

# FOR MULTIMONITOR
mkdir /tmp/polybar
polybar --log=error main 2>/tmp/polybar/main.log &
polybar --log=error ext 2>/tmp/polybar/ext.log &

# Wait for the processes to shut down
# while pgrep -x polybar >/dev/null; do sleep 1; done

# if type "xrandr"; then
#   for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#     MONITOR=$m polybar --reload main &
#   done
# else
#   polybar --reload main &
# fi
# feh --bg-scale ~/.config/wall.png


echo "Launched the bars..."
