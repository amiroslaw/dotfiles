#!/bin/bash

file=$*
# won't work with more mpv instances 
if [[ $(pgrep -x mpv) ]] && [[ -S /tmp/mpv.socket ]]; then
    echo "loadfile \"${file}\" append-play" | socat - /tmp/mpv.socket
else
    rm -f /tmp/mpv.socket
    mpv --x11-name=queue --title=queue --profile=stream --input-ipc-server=/tmp/mpv.socket --no-terminal --force-window=yes "$file" &
fi

# local CMD_VIDEO = 'mpv --profile=stream '
# local CMD_POPUP = 'mpv --x11-name=videopopup --profile=stream-popup '
# local CMD_AUDIO = 'st -c audio -e mpv --profile=stream-audio '
