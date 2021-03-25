#!/bin/bash
## usage: ./download_magnet_url.sh "magnet_link"
## magnet link shoul be enclosed in quotes.

cd $TOR_WATCH # set your watch directory here
[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit;
echo "d10:magnet-uri${#1}:${1}e" > "meta-${BASH_REMATCH[1]}.torrent"

notify-send "⬇️  Start downloading File 📁"
#używanie
# cd ~/bittorrent
# ./download_magnet_url.sh "magnet_link"
