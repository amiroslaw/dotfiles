#!/bin/bash

sessionDir="$HOME/.local/share/qutebrowser/sessions" 

if [[ "$1" == "webapp"  ]]; then
	sessionDir="$HOME/Templates/webapp-qt/data/sessions" 
fi

session=$(ls -1p "$sessionDir" | grep -v / | rofi -dmenu -monitor -4 -p "qb session $1")

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
	# "webapp" ) qutebrowser --config-py ~/.config/qutebrowser/config.py --basedir ~/Templates/webapp-qt ":session-load ${session/\.yml/}"
	"webapp" ) qutebrowser --config-py ~/.config/qutebrowser/config.py --basedir ~/Templates/webapp-qt --restore "${session/\.yml/}"
		;;
	* ) qutebrowser --restore "${session/\.yml/}"
		;;
esac