#!/bin/bash
# screencast active window 
# https://blog.sebastian-daschner.com/
# needs xwininfo
set -eo pipefail

pidfile=/tmp/screencast.lock

if [ -e $pidfile ]; then
    pid=`cat $pidfile`
    echo "Already running as ID $pid, now quitting"
    rm $pidfile
    kill -15 $pid
    exit 0
fi

# if [[ "$1" == "" ]]; then
#   echo "Usage: ${0##*/} <window-id>"; exit 2
# fi

# windowId=$1
windowId=$(xdotool getactivewindow)
tmpFile=/tmp/screencast-$(date +%s).mkv
paletteFile=/tmp/palette-$(date +%s).png
gifFile=/tmp/screencast-$(date +%s).gif

size=$(xdotool getwindowgeometry $windowId | grep Geometry | awk '{print $2}')
posX=$(xwininfo -id $windowId | grep 'Absolute upper-left X' | awk '{print $4}')
posY=$(xwininfo -id $windowId | grep 'Absolute upper-left Y' | awk '{print $4}')
pos="$posX,$posY"

ffmpeg -hide_banner -loglevel info -f x11grab -show_region 1 -video_size $size -i :0+$pos $tmpFile &
ffPID=$!
echo $ffPID > $pidfile
wait $ffPID && echo

ffmpeg -y -i $tmpFile -vf fps=10,palettegen $paletteFile
ffmpeg -i $tmpFile -i $paletteFile -filter_complex "paletteuse" $gifFile

rm $paletteFile $tmpFile
