#!/bin/bash 
en=$(rofi -lines 1 -width 30 -dmenu -p "enpl-txt:")
pl=$(trans -sp en:pl -no-ansi -show-prompt-message n -show-languages n "$en" | tee /tmp/translate-enpl.txt | awk 'NR==3,NR==4{if($0!="") print $1}') 
st -t "translator" -e less /tmp/translate-enpl.txt
echo "$en ; $pl" >> $CONFIG/logs/dictionary/enpl-dictionary.txt

# rofi -lines 1 -width 30 -dmenu -p "enpl-txe:" | trans -sp en:pl -no-ansi -show-prompt-message n -show-languages n -o /tmp/translate-enpl.txt
