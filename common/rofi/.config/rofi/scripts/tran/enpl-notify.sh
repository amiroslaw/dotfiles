trans -b -sp en:pl $1 | while read OUTPUT; do notify-send "$OUTPUT"; done
