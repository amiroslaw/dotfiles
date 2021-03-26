#/bin/bash
# rmplaying.sh for mplayer client
# only works when exactly 1 instance of mplayer is running

# PID=`pidof mplayer`
# WHICH=`which mplayer`
PID=`pidof mpv`
WHICH=`which mpv`
if [ $PID ]; then
	FILE=$(lsof -p $PID | awk '! /cache/ { if ($5=="REG" && $4!="mem" && $9)print $0 }' | grep -v "DEL" | grep -v "$WHICH" | grep -oP '\/.*')
fi

#FILE="$(playing)"
echo "file: $FILE"
if [ "$FILE" ]; then
  # trash-put "$FILE" && echo "Removed '$FILE'"
  trash-put "$FILE" && notify-send "Removed '$FILE'"
fi
