#!/bin/bash
session=$(ls -1p "$HOME/.local/share/qutebrowser/sessions" | grep -v / | rofi -dmenu -monitor -4 -p 'qb session')
if [ "$session" == "" ]; then
	exit 0
fi

case "$1" in
	"save" ) qutebrowser ":session-save --only-active-window ${session/\.yml/}"
		;;
	"delete" ) qutebrowser ":session-delete ${session/\.yml/}"
		;;
	"load" ) qutebrowser ":session-load ${session/\.yml/}"
		;;
	"restore" ) qutebrowser --restore "${session/\.yml/}"
		;;
	* ) qutebrowser --restore "${session/\.yml/}"
		;;
esac
