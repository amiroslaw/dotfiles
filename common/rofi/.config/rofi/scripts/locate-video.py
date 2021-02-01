#!/usr/bin/env bash
# save into var and pass to rofi only names using awk, you can du it in du insted of find 
find -L ~/Videos -type f | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r smplayer
# xdg-open "$(locate ~/Documents ~/Downloads | rofi -threads 0 -width 100 -dmenu -i -p "locate:")" // only one file
# xdg-open "$(find -L ~/Videos -type f | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:")"
# find -L ~/Videos -type f
