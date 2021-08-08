#!/bin/bash 
en=$(rofi -lines 1 -width 30 -dmenu -p "en-pl:") 
pl=$(trans -b -sp en:pl "$en")
echo "$pl" | while read OUTPUT; do notify-send "$OUTPUT"; done
echo "$en ; $pl" >> $CONFIG/logs/dictionary/enpl-dictionary.txt

