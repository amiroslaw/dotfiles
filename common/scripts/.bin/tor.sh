#!/usr/bin/bash

cacheDir="/tmp/tor"
cacheFile="/tmp/tor/tor.html"
mkdir -p $cacheDir

if [ -z "$1" ]; then
  query=$(echo "" | rofi -dmenu -l 0 -p "Search Torrent: ")
else
  query=$1
fi
# doesn't exit
# baseurl="https://pirateproxy.live/search/"
baseurl="https://pirateproxylive.org/search/"
query="${query// /%20}"
curl -s $baseurl"$query" > $cacheFile

# Get data
pup 'tbody tr td div.detName a[title] text{}' -f $cacheFile > $cacheDir/titles
pup 'tbody tr td font.detDesc text{}' -f $cacheFile > $cacheDir/desc
awk 'BEGIN{FS=","} {print $2}' $cacheDir/desc | awk 'NF' > $cacheDir/sizes
pup -p 'tbody tr td:nth-child(2) a:nth-child(2) attr{href}' -f $cacheFile > $cacheDir/magnets
pup 'tbody tr td:nth-child(3) text{}' -f $cacheFile > $cacheDir/seeds
pup 'tbody tr td:nth-child(4) text{}' -f $cacheFile > $cacheDir/leeches

# # Clearning up some data to display
awk '{print NR "- [S:"$0 ","}' $cacheDir/seeds > $cacheDir/tmp && mv $cacheDir/tmp $cacheDir/seeds
awk '{print "L:"$0"]" }' $cacheDir/leeches > $cacheDir/tmp && mv $cacheDir/tmp $cacheDir/leeches

# Getting the line number
LINE=$(paste -d\  $cacheDir/seeds $cacheDir/leeches $cacheDir/sizes $cacheDir/titles |
	# dmenu -i -l 52 |
	rofi -dmenu -i -theme-str 'window {width: 1050px;}' -monitor -4 -l 30 |
	awk 'BEGIN{FS="-"} {print $1}')

if [ -z "$LINE" ]; then
  notify-send "😔 No Result selected. Exiting... 🔴" -i "NONE"
  exit 0
fi
notify-send "🔍 Searching Magnet seeds 🧲" -i "NONE"
magnet=$(head -n $LINE $cacheDir/magnets | tail -n +$LINE)

url.lua --tor "$magnet"
# # magnet.sh "$magnet"
