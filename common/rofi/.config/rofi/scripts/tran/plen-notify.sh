trans -b -p pl:en "$1" | while read OUTPUT; do notify-send "$OUTPUT"; done
