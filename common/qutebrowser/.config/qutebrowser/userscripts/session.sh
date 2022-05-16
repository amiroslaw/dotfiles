#!/bin/bash

session=$(ls -1 "$HOME/.local/share/qutebrowser/sessions" | rofi -dmenu -monitor -4 -p 'qb session')
if [ "$session" == "" ]; then
	exit 0
fi
if [[ "$1" == "save" ]]; then
	qutebrowser ":session-save --only-active-window ${session/\.yml/}"
elif [[ "$1" == "delete" ]]; then
	qutebrowser ":session-delete ${session/\.yml/}"
else
	qutebrowser ":session-load ${session/\.yml/}"
fi
