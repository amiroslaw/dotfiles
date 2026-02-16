#!/bin/sh

notify-send "$(gcalcli  --nocolor agenda $(date -d "today" +%F) $(date -d "5 day" +%F) --config-folder="/home/miro/.config/gcalcli")" -u critical
