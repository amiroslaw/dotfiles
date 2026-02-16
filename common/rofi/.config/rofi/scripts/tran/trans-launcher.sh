#!/bin/sh

# peeks="dic|en-p|pl-e|txt-en-p|txt-pl-e"
peeks="en-p|pl-e|txt-en-p|txt-pl-e|dic|list"
peek=$(echo $peeks | rofi -moniotor -4 -width -24 -lines 6 -sep '|' -dmenu -p "Choose mode")

case "$peek" in
	dic) ~/.config/rofi/scripts/tran/selfrunning/dic.sh ;;
	txt-en-p) ~/.config/rofi/scripts/tran/selfrunning/enpl-txt.sh ;;
	txt-pl-e) ~/.config/rofi/scripts/tran/selfrunning/plen-txt.sh ;;
	en-p) ~/.config/rofi/scripts/tran/selfrunning/enpl-notify.sh ;;
	pl-e) ~/.config/rofi/scripts/tran/selfrunning/plen-notify.sh ;;
	list) ~/.config/rofi/scripts/tran/dictionary-list.sh ;;
esac
