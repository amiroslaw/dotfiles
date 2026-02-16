#!/bin/bash 
pl=$(rofi -lines 1 -width 30 -dmenu -p "plen-txt:")
en=$(trans -p pl:en -no-ansi -show-prompt-message n -show-languages n "$pl" | tee /tmp/translate-plen.txt | awk 'NR==3 {print $1}')
echo "$en ; $pl" >> $CONFIG/logs/dictionary/enpl-dictionary.txt
st -t "translator" -e less /tmp/translate-plen.txt
