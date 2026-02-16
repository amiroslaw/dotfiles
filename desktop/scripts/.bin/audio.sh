#!/usr/bin/env bash
set -o pipefail

if [[ "$1" == toggle ]]; then
	SPEAKERS=$(pacmd list-cards | grep 'active' | grep '21')

	if [[ -n "$SPEAKERS"  ]]; then
		pactl set-card-profile 2 output:analog-surround-40
	else
		pactl set-card-profile 2 output:analog-surround-21
	fi
	exit 0
fi

SELECTION=$( echo "speakers|headset|microphone" | rofi -dmenu -threads 0 -monitor -4 -i -l 3 -sep "|" -p audio)

case $SELECTION in
	headset )
		pactl set-card-profile 2 output:analog-surround-40
		;;
	microphone )
		pactl set-card-profile 2 output:analog-surround-40+input:analog-stereo
		;;
	* )
		pactl set-card-profile 2 output:analog-surround-21
		;;
esac

