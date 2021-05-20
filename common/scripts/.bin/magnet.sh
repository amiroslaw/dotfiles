#!/bin/bash
## usage: ./download_magnet_url.sh "magnet_link"
## magnet link shoul be enclosed in quotes.

link=$1
if [ -z "$1" ]
  then
	link=$(xclip -o -sel clip)
fi
cd $TOR_WATCH # set your watch directory here
[[ "$link" =~ xt=urn:btih:([^&/]+) ]] || exit;
echo "d10:magnet-uri${#link}:${link}e" > "meta-${BASH_REMATCH[1]}.torrent"

notify-send "⬇️  Start downloading File 📁"
#używanie
# cd ~/bittorrent
# ./download_magnet_url.sh "magnet_link"
