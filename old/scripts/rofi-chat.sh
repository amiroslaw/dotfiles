#!/bin/bash
INPUT=$(rofi -monitor -4 -l 0 -width 23 -dmenu -p "  ") 
DATE_STAMP=$(date +%d-%H%M%S)
FILE="/tmp/txt/ollama-${DATE_STAMP}.txt"
mkdir -p /tmp/txt

if [[ -z $INPUT ]]; then 
	exit 1 
fi

zenity --progress --text="Waiting for an answer" --pulsate &

if [[ $? -eq 1 ]]; then
	exit 1 
fi

PID=$!
ANSWER=$(ollama run mistral:7b "$INPUT") 
echo "$ANSWER" > "$FILE"
kill $PID 
st -c chat -n chat -e nvim "$FILE"
# zenity --info --text="$ANSWER"
# wezterm start --class read -- nvim  $FILE

