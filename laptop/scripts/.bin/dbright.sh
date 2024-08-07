#!/bin/sh
###

if ! [ -f "$HOME/.dmenurc" ]; then
	cp /usr/share/dmenu/dmenurc $HOME/.dmenurc
fi
. $HOME/.dmenurc

eval $(xdotool getmouselocation --shell)
menu_widht=50
monitor_widht=$(wattr w $(lsw -r))
monitor_height=$(wattr h $(lsw -r))
lines=14
menu_height=$(( $lines * 23 ))
maxx=$(( $monitor_widht - $menu_widht ))
miny=$PANEL_HEIGHT
maxy=$(( $monitor_height - $menu_height ))
XP=$(( $X - 15 ))
[ $XP -gt $maxx ] && XP=$maxx
YP=$Y
[ $YP -lt $miny ] && YP=$miny
[ $YP -gt $maxy ] && YP=$maxy

#DMENU='dmenu -i -l 5 -y 30 -x 1720 -w 200 -fn sans11 -nb '#000000' -nf '#99CC99' -sb '#99CC99' -sf '#000000''
#DMENU='dmenu $DMENU_OPTIONS'
choice=$(printf "100\n70\n50\n30\n10" | rofi -config "~/.config/rofi/config-monocle.rasi" -theme-str "#window { location: northwest; border: 0; height: 240; width: 80; y-offset: ${YP}px; x-offset: ${XP}px;}" -dmenu -p "")

case "$choice" in
  100) light -S 100 & ;;
  70) light -S 70 & ;;
  50) light -S 50 & ;;
  30) light -S 30 & ;;
  10) light -S 10 & ;;
esac
