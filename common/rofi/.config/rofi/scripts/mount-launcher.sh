#!/bin/sh

# peeks="dic|en-p|pl-e|txt-en-p|txt-pl-e"
peeks="1-zamontuj|2-odmontuj"
peek=$(echo $peeks | rofi -width 20 -lines 8 -sep '|' -dmenu -p "Choose mode > ")

case "$peek" in
	1-zamontuj) /home/miro/.config/rofi/scripts/mount/mount ;;
	2-odmontuj) /home/miro/.config/rofi/scripts/mount/umount ;;
esac
