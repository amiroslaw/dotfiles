#!/usr/bin/env bash

fd --follow  --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg --search-path ~/Videos | rofi -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r $VIDEO

# fd --follow --full-path --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg ~/Videos | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r $VIDEO
# find
# find -L ~/Videos -type f | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r xdg-open
# xdg-open "$(find -L ~/Videos -type f | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:")"
# xdg-open "$(locate ~/Documents ~/Downloads | rofi -threads 0 -width 100 -dmenu -i -p "locate:")" // only one file
