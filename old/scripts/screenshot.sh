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
DIR="$HOME/Pictures/Screens"
# Makes sure the directory exists.
mkdir -p "${DIR}"

# FIX: STAMP will be set to the time when this script was executed and not when the actual screenshot is taken
STAMP=$(date '+%y-%m-%dT%H%M%S')
getPartialPath () {
	windowName="$(xdotool getactivewindow getwindowname)"
	partialPath="$DIR"/"$windowName"-"$STAMP"
}
# -f 'jpg' filetype
	# maim -m 10 -f webp -i $(xdotool getactivewindow) "$partialPath"_sc.webp
case "$1" in
  'window')
	getPartialPath
	# maim -i $(xdotool getactivewindow) "$partialPath"_sc.png
	maim -f webp -i $(xdotool getactivewindow) "$partialPath"_sc.webp
  ;;
  'quality')
	getPartialPath
	maim -m 10 -f webp -i $(xdotool getactivewindow) "$partialPath"_sc.webp
  ;;
  'selection')
	getPartialPath
	maim -f webp -s "$partialPath"_Ssc.webp
  ;;
  'clipboard')
	# doesn't work with webp
    maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png 
  ;;
  'monitor1')
	maim -f webp -g $(xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' 'NR==1 {print $2"x"$4"+"$6"+"$7}') "$DIR"/"$STAMP"_Fsc.webp
  ;;
  'monitor2')
	maim -f webp -g $(xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' 'NR==2 {print $2"x"$4"+"$6"+"$7}') "$DIR"/"$STAMP"_Fsc.webp
  ;;
  *)
	getPartialPath
	maim -f webp -i $(xdotool getactivewindow) "$partialPath"_sc.webp
  ;;
esac

# -m, --quality An  integer  from  1 to 10 that determines the compression quality. For lossy formats (jpg and webp), lower settings will produce smaller files with lower quality, while  higher  settings  will  increase quality  at  the  cost of higher file size. A quality of 10 is lossless for webp. For png, lower set‐ tings will compress faster and produce larger files, while higher settings will compress slower,  but produce smaller files. No effect on bmp images. 

notify-send "Screenshot saved - $1"
