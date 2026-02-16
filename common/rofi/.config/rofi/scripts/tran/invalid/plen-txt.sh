# trans -p pl:en -show-prompt-message n -show-languages n -o /tmp/translate-plen.txt
# st -e less /tmp/translate-plen.txt
# trans -p pl:en -show-prompt-message n -show-languages n $1 | while read OUTPUT; do st -e less "$OUTPUT"; done
st -e less $(trans -p pl:en -show-prompt-message n -show-languages n $1)
