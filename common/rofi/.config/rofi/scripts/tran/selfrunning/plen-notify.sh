#!/bin/bash 
pl=$(rofi -lines 1 -width 30 -dmenu -p "pl-en:") 
en=$(trans -b -p pl:en "$pl")
echo "$en" | while read OUTPUT; do notify-send "$OUTPUT"; done
echo "$en ; $pl" >> $CONFIG/logs/dictionary/enpl-dictionary.txt

# rofi -lines 1 -width 30 -dmenu -p "plen:" | trans -b -p pl:en | while read OUTPUT; do notify-send "$OUTPUT"; done
