#!/bin/bash

if [ $1 == "play" ]; then
echo "play mpv"
    # mpv --fs --playlist=/tmp/playlist --input-ipc-server=/tmp/mpvsocket
	mpv --fs --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --ytdl-format="bestvideo[height<=?1080][vcodec!=vp9]+bestaudio/best" --input-ipc-server=/tmp/mpvsocket --playlist=/tmp/mpvplaylist.m3u
    rm -f /tmp/mpvplaylist.m3u
fi 

if [ $1 == "push" ]; then
    echo $2 >> /tmp/playlist
fi 

