#!/bin/bash 
en=$(rofi -lines 1 -width 30 -dmenu -p "dic:")
# trans -sp en: -no-ansi -show-prompt-message n -show-languages n -o /tmp/dic.txt $en
# i tak zapisuje do jednego pliku, tu trzeba pętli
# echo $en | awk 'BEGIN{RS=" "} {print $0}' | trans -sp en: -no-ansi -show-prompt-message n -show-languages n -o /tmp/dic.txt
# echo $en | tr ' ' '\n' | trans -sp en: -no-ansi -show-prompt-message n -show-languages n -o /tmp/dic.txt
echo $en >> $CONFIG/logs/dictionary/enpl-dictionary.txt
st -t "translator" -e less /tmp/dic.txt

# trans -sp en: -no-ansi -show-prompt-message n -show-languages n -o /tmp/dic.txt  $(rofi -lines 1 -width 30 -dmenu -p "dictionary:") 
