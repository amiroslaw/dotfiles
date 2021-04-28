#!/usr/bin/env bash
#
# Script name: screenshot
# Description: Screenshot to take with maim.
# Dependencies: maim, xdotool, xclip

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# Specifying a directory to save our screenshots.
DIR="$HOME/Pictures"
# Makes sure the directory exists.
mkdir -p "${DIR}"

# FIX: STAMP will be set to the time when this script was executed and not when the actual screenshot is taken
STAMP=$(date '+%m-%d-%H%M%S')


case "$1" in
  'window')
	maim -i $(xdotool getactivewindow) "$DIR"/"$STAMP"_sc.png
  ;;
  'quality')
	maim -m 2 -i $(xdotool getactivewindow) "$DIR"/"$STAMP"_Qsc.png
  ;;
  'selection')
	maim -s "$DIR"/"$STAMP"_Ssc.png
  ;;
  'clipboard')
    maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png
  ;;
  'monitor1')
	maim -g $(xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' 'NR==1 {print $2"x"$4"+"$6"+"$7}') "$DIR"/"$STAMP"_Fsc.png
  ;;
  'monitor2')
	maim -g $(xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' 'NR==2 {print $2"x"$4"+"$6"+"$7}') "$DIR"/"$STAMP"_Fsc.png
  ;;
  *)
	maim -i $(xdotool getactivewindow) "$DIR"/"$STAMP"_sc.png
  ;;
esac

notify-send "Screenshot saved - $1"
